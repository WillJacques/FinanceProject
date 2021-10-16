Rails.application.routes.draw do
  resources :portfolios
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  root 'stocks#index'
  # devise_scope :users do
  #   get '/signout', to: 'devise/sessions#destroy', as: :signout
  # end

  resources :stocks
  post '/stocks/search' => 'stocks#search'
  get '/stocks/candlestick/:id' => 'stocks#candlestick', as: 'stocks_candlestick'

  resources :users
  get '/users/last_query/:id' => 'users#last_query', as: 'users_last_query'
end
