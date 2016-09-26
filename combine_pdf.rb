require 'pry'
START = ENV["START"]&.to_i || 0
LIMIT = ENV["LIMIT"]&.to_i
SKIP_STEP_1 = ENV["SKIP_STEP_1"]
SKIP_STEP_2 = ENV["SKIP_STEP_2"]

def convert_cmd(paths_str, dest)
  "convert -density 300x300 -quality 100 #{paths_str} #{dest}"
end

def combine_step_1
  paths = Dir.glob("./pdf/*").to_a[START..-1]
  paths = LIMIT ? paths.first(LIMIT) : paths
  group_lengths = 5 # can only combine 5 pdfs
  `mkdir pdf_tmp`
  `rm pdf_tmp/*`
  start_idx = 0
  paths.each_slice(group_lengths).to_a.each do |paths|
    end_idx = start_idx + group_lengths
    dest = "./pdf_tmp/#{start_idx}-#{end_idx}-merged.pdf"
    paths_str = paths.join " "
    cmd = convert_cmd(paths_str, dest)
    puts cmd
    `#{cmd}` 
    start_idx = end_idx
  end
end

def combine_step_2
  paths = Dir.glob("./pdf_tmp/*")
  first_path = paths.sort.shift # create a merged.pdf file to start out with
  `mv #{first_path} merged.pdf`
  merged_tmp_path = "./pdf_tmp/merged2.pdf"
  paths.each do |path|
    cmd = convert_cmd("#{path} ./merged.pdf", merged_tmp_path)
    puts cmd
    `#{cmd}`
    `rm ./merged.pdf`
    `mv #{merged_tmp_path} ./merged.pdf`  
    `rm #{path}`
  end
end


if __FILE__ == $0
  combine_step_1 unless SKIP_STEP_1
  combine_step_2 unless SKIP_STEP_2
end
