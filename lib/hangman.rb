require 'rubygems'
require 'json'
require 'uri'
require 'net/http'
require 'net/https'

module Hangman
  WORDS_CACHE = "../config/words"

  if File.exist? WORDS_CACHE
    WORDS = File.open(WORDS_CACHE) { |file| Marshal.load(file) }
  else
    WORDS = File.open("../config/words3.txt") do |dict|
      dict.inject(Hash.new) do |all, word|
        all.update(word.delete("^A-Za-z").upcase => true)
      end.keys.sort_by { |w| [w.length, w] }
    end
    File.open(WORDS_CACHE, "w") { |file| Marshal.dump(WORDS, file) }
  end

  def self.frequency(words)
    freq = Hash.new(0)
    words.each do |word|
      word.split("").each { |letter| freq[letter] += 1 }
    end
    freq
  end

  FREQ = frequency(WORDS).sort_by { |_, count| -count }.map { |letter, _| letter }

  def self.post(url, data)
    uri = URI.parse(url)
    header = { 'Content-Type' => 'application/json' }
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri, header)
    req.body = data.to_json
    return JSON.parse(https.request(req).body)
  end

  class Player
    def initialize(url, id)
      @url = url
      @id = id
    end

    attr_reader :numberOfWordsToGuess

    def start
      data = {
        playerId: @id,
        action: "startGame"
      }
      resp = ::Hangman.post(@url, data)
      @numberOfWordsToGuess = resp["data"]["numberOfWordsToGuess"]
      @numberOfGuessAllowedForEachWord = resp["data"]["numberOfGuessAllowedForEachWord"]
      @sessionId = resp["sessionId"]
    end

    def nextWord
      data = {
        sessionId: @sessionId,
        action: "nextWord"
      }
      resp = ::Hangman.post(@url, data)
      @currentWord = resp["data"]["word"]
    end

    def guessAWord
      candidates = WORDS
      guesses = Array.new
      totalWrong = 0
      wrongGuess = 'a'
      while @currentWord.include?('*') && totalWrong < @numberOfGuessAllowedForEachWord do
        puts "~~>currentPattern: #{@currentWord}"
        candidates = candidates.grep(/\A#{@currentWord.tr('*', '.')}\Z/i).reject { |w| w.include? wrongGuess }
        puts "+++candidatesCount: #{candidates.length}, (first..tenth): #{candidates[0..9]}"
        break if candidates.empty?
        guess = ::Hangman.frequency(candidates).
                  reject { |letter, _| guesses.include? letter }.
                  sort_by { |letter, count| [-count, FREQ.index(letter)] }.
                  first.first rescue nil
        guess = guess ? guess : (FREQ - guesses).first
        puts "???guess: #{guess}"
        guesses << guess
        data = {
          sessionId: @sessionId,
          action: "guessWord",
          guess: guess
        }
        resp = ::Hangman.post(@url, data)
        if resp["data"]["word"] == @currentWord
          wrongGuess = guess
        else
          @currentWord = resp["data"]["word"]
          wrongGuess = 'a'
        end
        totalWrong = resp["data"]["wrongGuessCountOfCurrentWord"]
      end
      puts "-->currentGuessResult: #{@currentWord}"
    end

    def getResult
      data = {
        sessionId: @sessionId,
        action: "getResult"
      }
      return ::Hangman.post(@url, data)
    end

    def submit
      data = {
        sessionId: @sessionId,
        action: "submitResult"
      }
      return ::Hangman.post(@url, data)
    end
  end
end
