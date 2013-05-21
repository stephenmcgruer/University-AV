#!/usr/bin/env ruby

if ARGV.length != 1
  puts "Not enough args!"
  exit
end

samples = ["1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", 
           "2.1", "2.2", "2.3", "2.4", "2.5", "2.6",
           "3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8", "3.9"]

classes = [2, 2, 2, 1, 1, 1, 3, 3, 3, 3, 2, 1, 3, 2, 1, 1, 1, 1, 3, 3, 3,
           2, 2, 2]

File.open(ARGV[0], "r").each_with_index do |line, i|
  features = line.strip.split(/\s\s*/)
  puts "\\hline"
  print samples[i]
  features.each do |feature|
    print " & " + feature
  end
  print " & " + classes[i].to_s + " \\\\\n"
end
