#!/usr/bin/env ruby

require '../lib/hangman.rb'

I = Hangman::Player.new("https://strikingly-hangman.herokuapp.com/game/on", "shiwen_l@126.com")


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

pre_score = File.exist?("../scores") ? IO.readlines("../scores")[-1].to_i : 0
File.open("../scores", 'a'){ |f| f.puts score }

if score > pre_score
  sub_res = I.submit
  puts '%%%%%%%%%%%%%%%%%%%%%%%%'
  puts ">>>Session #{sub_res['sessionId']} submitted at #{sub_res['data']['datetime']}."
end
