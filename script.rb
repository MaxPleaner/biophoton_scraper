# load up dependencies
require 'pry'
require 'tempfile'
require 'colored'
require 'active_support/all'
require 'pdfkit'
require 'dotenv'
Dotenv.load
require 'mechanize'
mechanize = Mechanize.new

Continue_From = ENV["Continue_From"] || 0

class Biophoton_Downloader
  attr_reader :mechanize
  attr_accessor :idx
  def initialize(mechanize)
    @mechanize = mechanize
    @idx = 1
  end
  def login
    login_url = "http://www.biontology.com/vanilla/index.php?p=/entry/signin&Target=discussions"
    login_page = mechanize.get login_url
    login_form = login_page.forms[1] 
    login_form.fields[4].value = ENV["Biophoton_Username"]
    login_form.fields[5].value = ENV["Biophoton_Password"] 
    login_form.submit
  end

  def download_individual_articles
    url = "http://www.biontology.com/vanilla/index.php?p=/discussions/p"
    1.upto(36).each do |page_idx|
      page_url = url + page_idx.to_s
      page = mechanize.get page_url
      links = page.css("#Content").css(".Title").css("a").each do |link|
        download_links link.attr 'href'
      end
    end
  end
  def download_links(url)
    unless idx < Continue_From
      page = mechanize.get url
      html = page.at("#Content").to_s
      title = page.title.parameterize
      save_plaintext_version html, title
      save_html_version html, title
      # save_pdf_version html, title
      self.idx += 1
    end
  end
  def save_html_version(html, title)
    filename="html/#{idx.to_s.rjust(4, "0")}#{title}.html"
    File.open(filename, 'w') { |f| f.write html }
    puts "created html: ".yellow + title
  end
  def save_plaintext_version(html, title)
    filename = "plaintext/#{idx.to_s.rjust(4, "0")}#{title}.txt"
    tmpfile = Tempfile.new "biophoton-downloader"
    tmpfile.write html
    plaintext = `cat #{tmpfile.path} | w3m -dump -T text/html`
    tmpfile.unlink
    File.open filename, 'w' do |file|
      file.write plaintext
    end
    puts "created plaintext: ".yellow + title
  end
  def save_pdf_version(html, title)
    filename = "#{`pwd`.chomp}/pdf/#{idx.to_s.rjust(4, "0")}#{title}.pdf"
    kit = PDFKit.new(html, :page_size => 'Letter')
    pdf = kit.to_pdf
    file = kit.to_file(filename)
    puts "created pdf: ".blue + title
  end
end

if __FILE__ == $0
  scraper = Biophoton_Downloader.new(mechanize)
  scraper.instance_exec do
    login
    download_individual_articles
  end
end
