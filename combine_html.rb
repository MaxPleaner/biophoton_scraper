def with_boiler(html)
  <<-HTML
  <!doctyle html>
  <html lang='en'>
  <head>
  </head>
  <body>
  #{html}
  </body>
  </html>
  HTML
end

text = Dir.glob("./html/*.html").map do |path|
  File.read path
end.join("<hr")

File.open("result.html", 'w') { |f| f.write with_boiler text }