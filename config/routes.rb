Artfully::Application.routes.draw do

  scope :module => :api do
    constraints :subdomain => "api" do
      resources :events, :only => :show
      resources :tickets, :only => :index
    end
  end

  namespace :store do
    resources :events, :only => :show
  end

  namespace :admin do
    root :to => "index#index"
    resources :users
    resources :organizations do
      resources :kits do
        put :activate, :on => :member
      end
    end
  end

  devise_for :users

  resources :organizations
  resources :kits
  resources :credit_cards, :except => :show

  resources :people, :only => [:index, :show, :edit, :update]
  resources :performances

  resources :events do
    resources :performances
  end

  resources :charts do
    resources :sections
  end

  resource :order, :defaults => { :format => :widget }, :only => [:show, :create, :update, :destroy ]
  resource :checkout

  match '/performances/:id/duplicate/' => 'performances#duplicate', :as => :duplicate_performance
  match '/events/:event_id/charts/assign/' => 'charts#assign', :as => :assign_chart
  match '/performances/:id/createtickets/' => 'performances#createtickets', :as => :create_tickets_for_performance
  match '/performances/:id/put_on_sale/' => 'performances#put_on_sale', :as => :put_performance_on_sale
  match '/performances/:id/take_off_sale/' => 'performances#take_off_sale', :as => :take_performance_off_sale
  match '/performances/:performance_id/tickets/bulk_edit' => 'tickets#bulk_edit', :as => :bulk_edit_performance_tickets

  root :to => "index#index"
end
