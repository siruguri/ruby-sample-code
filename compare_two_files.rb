require 'pry'

@file1 = File.open(ARGV[0], 'r').readlines
@file2 = File.open(ARGV[1], 'r').readlines


def remove_quotes(s)
  s = s.chomp
  s.gsub! /^"/, ''
  s.gsub! /"$/, ''
  s = s.strip
  s.downcase
end

@file1.each_with_index do |l, index|
  l = remove_quotes l
  @file2[index] = remove_quotes @file2[index]

  if l != @file2[index]
    puts (0..l.length).find { |char_index| l.chomp.downcase[char_index] != @file2[index].chomp.downcase[char_index] }
    binding.pry
      
  end
end
