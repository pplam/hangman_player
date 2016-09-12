require './hangman.rb'

I = Hangman::Player.new("https://strikingly-hangman.herokuapp.com/game/on", "shiwen_l@126.com")


puts "New game started with sessionId: #{I.start}"

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
puts "totalWordCount: #{resp['data']['totalWordCount']}"
puts "correctWordCount: #{resp['data']['correctWordCount']}"
puts "totalWrongGuessCount: #{resp['data']['totalWrongGuessCount']}"
puts "score: #{score}"
puts

pre_score = File.exist?("../tmp/scores") ? IO.readlines("../tmp/scores")[-1].to_i : 0

if score > pre_score
  sub_res = I.submit
  File.open("../tmp/scores", 'a'){ |f| f.puts score }
  puts '%%%%%%%%%%%%%%%%%%%%%%%%'
  puts "Session #{sub_res['sessionId']} submitted at #{sub_res['data']['datetime']}."
end
