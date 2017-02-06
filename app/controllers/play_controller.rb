require 'open-uri'
require 'json'

class PlayController < ApplicationController
  def game
    @gridsize = params[:gridsize]
    @grid = generate_grid(@gridsize.to_i)
    @start_time = Time.now
  end

  def score
    @grid = JSON.parse(params[:grid])
    @attempt = params[:attempt]
    @end_time = Time.now
    @beginning = Time.parse(params[:start])
    run_game(@attempt, @grid, @beginning, @end_time)
    @time = @end_time - @beginning
    @translation = get_translation(@attempt)
    @result = score_and_message(@attempt, @translation, @grid, @time)
  end

  def home
  end

private

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def run_game(attempt, grid, start_time, end_time)
    return run_game_verified(attempt, grid, start_time, end_time)
  end

  def included?(guess, grid)
    guess.split("").all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt.upcase, grid)
      if translation
        score = compute_score(attempt, time)
        [score, "Well Done"]
      else
        [0, "Not an english word"]
      end
    else
      [0, "Not in the grid"]
    end
  end

  def get_translation(word)
    api_key = "YOUR_SYSTRAN_API_KEY"
    # begin
    #   response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
    #   json = JSON.parse(response.read.to_s)
    #   if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
    #     return json['outputs'][0]['output']
    #   end
    # rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
        return word
      else
        return nil
      end
    # end
  end









  # def translation(attempt)
  #   key = "c685a12a-1d10-4746-9cef-ebf77839e8cf"
  #   # begin
  #   #   url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr"
  #   #   final_url = "#{url}&key=#{key}&input=#{attempt.downcase}"
  #   #   translation_serialized = open(final_url).read
  #   #   translate = JSON.parse(translation_serialized)
  #   #   return translate["outputs"][0]["output"]
  #   # rescue
  #     if File.read('/usr/share/dict/words').upcase.split("\n").include? attempt.upcase
  #       return attempt
  #     else
  #       return nil
  #     end
  #   # end
  # end

  # def run_game_verified(attempt, grid, start_time, end_time)
  #   # TODO: runs the game and return detailed hash of result
  #   result = { time: 0, translation: nil, score: 0, message: "" }
  #   if ((attempt.upcase.split(//) - grid).empty? == false)
  #     result = { time: 0, translation: nil, score: 0, message: "not in the grid" }
  #   else
  #     point = (attempt.length / (end_time - start_time)).to_i
  #     result = { time: end_time - start_time, translation: translation(attempt), score: point, message: "well done" }
  #   end
  #   return result
  # end

end
