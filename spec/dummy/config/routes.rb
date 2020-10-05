Rails.application.routes.draw do
  root to: 'api#index'
  get '/outgoing', to: 'api#outgoing_request'
  get '/incoming', to: 'api#incoming_request'
end
