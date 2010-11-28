Artfully::Application.routes.draw do
  devise_for :users

  resources :user_roles
  resources :users, :only => [:show] do
    resources :credit_cards
    resources :user_roles
  end

  resources :tickets, :only => [:index, :show]

  resources :orders
  resources :events do
    resources :performances
  end

  match '/performances/:id/duplicate/' => 'performances#duplicate', :as => :duplicate_performance

  root :to => "index#index"
end
