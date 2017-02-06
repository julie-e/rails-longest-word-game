Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
root to: "play#home"

get "game" => "play#game"

get "score" => "play#score"

end
