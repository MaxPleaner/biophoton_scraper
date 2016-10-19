delimiter = "\n\n=====================================================\n\n"

text = Dir.glob("plaintext/*.txt").reduce("") do |result, path|
  result += "#{File.read path}#{delimiter}"
end

File.open("result.txt", 'w') { |f| f.write text }