#!/usr/bin/env ruby

require '../lib/hangman.rb'
require 'date'
require 'yaml'

account = YAML.load_file('../config/config.yaml')

I = Hangman::Player.new(account["url"], account["id"])


puts "===New game started with sessionId: #{I.start}"

i = 0
while i < I.numberOfWordsToGuess do
  puts '##########################'
  I.nextWord
  I.guessAWord
  i += 1
  puts
end

resp = I.getResult
score = resp["data"]["score"]
puts '/////////////////////////'
puts "| totalWordCount: #{resp['data']['totalWordCount']}"
puts "| correctWordCount: #{resp['data']['correctWordCount']}"
puts "| totalWrongGuessCount: #{resp['data']['totalWrongGuessCount']}"
puts "| score: #{score}"
puts

max_score = File.exist?("../scores") ? IO.readlines('../scores').map{|l| l.split('@')[0].to_i }.max : 0
File.open("../scores", 'a'){ |f| f.puts "#{score}@#{DateTime.now.strftime('%e %b %Y %H:%M:%S%p')}" }

if score > max_score
  sub_res = I.submit
  puts '%%%%%%%%%%%%%%%%%%%%%%%%'
  puts ">>>Session #{sub_res['sessionId']} submitted at #{sub_res['data']['datetime']}."
end
