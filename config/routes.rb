Artfully::Application.routes.draw do

  resources :searches, only: [:new, :create, :show]

  namespace :api do
    resources :events, :only => :show
    resources :tickets, :only => :index
    resources :shows, :only => :show
    resources :organizations, :only => [] do
      resources :events
      resources :shows
      get :authorization
    end
  end

  namespace :store do
    resources :events, :only => :show
    resource :order, :only => [:show, :create, :update, :destroy, :storefront_sync] do
      collection do
        post :storefront_sync
      end 
    end
    resource :checkout do
      collection do
        post :storefront_create
      end 
    end
  end

  namespace :admin do
    root :to => "index#index"
    resources :users do
      post :sessions, :on => :member
    end

    resources :finances, :only => [ :index ]
    resources :shows, :only => [ :index ]
    resources :settlements, :only => [ :index, :new, :create ]
    resources :orders, :only => [ :index, :show ] do
      collection do
        get 'all'
        get 'artfully'
      end
    end
    resources :organizations do

      resources :events, :only => :show do
        resources :shows, :only => :show
      end

      resources :kits do
        put :activate, :on => :member
        put :cancel, :on => :member
      end

      resources :memberships
      resource  :bank_account, :except => :show
    end
    resources :kits
  end

  devise_for :users
  devise_scope :user do
    get "sign_up", :to => "devise/registrations#new"
  end
  devise_for :admins

  resources :organizations do
    resources :reseller_attachments
    resources :reseller_profiles
    resources :reseller_events do
      resources :reseller_attachments
      resources :reseller_shows do
        member do
          put :publish
          put :unpublish
        end
      end
    end
    put :tax_info, :on => :member
    resources :memberships
    member do
      post :connect
    end
  end

  resources :ticket_offers do
    collection do
      post "/new", :to => "ticket_offers#new"
      get "/create", :to => "ticket_offers#create"
    end
    member do
      get :accept
      get :decline
    end
  end

  resources :widgets, :only => [:new, :create]

  resources :export do
    collection do
      get :contacts
      get :donations
      get :ticket_sales
    end
  end

  resources :kits, :except => :index do
    get :alternatives, :on => :collection
    post :requirements, :on => :collection
    get :requirements, :on => :collection
  end

  resources :reports, :only => :index
  resources :settlements, :only => [ :index, :show ]
  resources :statements, :only => [ :index, :show ]


  resources :credit_cards, :except => :show

  resources :people, :except => :destroy do
    resources :actions
    resources :notes
    resources :phones, :only => [:create, :destroy]
    resource  :address, :only => [:create, :update, :destroy]    
  end
  resources :segments, :only => [:index, :show, :create]

  resources :events do
    get :widget,  :on => :member
    get :storefront_link,  :on => :member
    get :resell, :on => :member
    get :prices,  :on => :member
    get :image,   :on => :member
    get :messages,   :on => :member
    resources :shows do
      resource :sales, :only => [:new, :create, :show, :update]
      member do
        get :door_list
        post :duplicate
      end
      collection do
        post :built
        post :on_sale
        post :published
        post :unpublished
      end
    end
    resource :venue, :only => [:edit, :update]
  end

  resources :shows, :only => [] do
    resources :tickets, :only => [ :new, :create ] do
      collection do
        delete :delete
        put :on_sale
        put :off_sale
        put :bulk_edit
        put :change_prices
        get :set_new_price
      end
    end
  end

  resources :charts, :only => [:update] do
    resources :sections
  end
  
  resources :sections do
    collection do
      post :on_sale
      post :off_sale
    end
  end

  resources :help, :only => [ :index ]

  resources :orders do
    collection do
      get :sales
    end
    member do
      get :resend
    end
  end

  resources :contributions

  resources :refunds, :only => [ :new, :create ]
  resources :exchanges, :only => [ :new, :create ]
  resources :returns, :only => :create
  resources :comps, :only => [ :new, :create ]
  resources :merges, :only => [ :new, :create ]

  resources :imports do
    member do
      get :approve
    end
    collection do
      get :template
    end
  end

  match '/events/:event_id/charts/' => 'events#assign', :as => :assign_chart, :via => "post"
  match '/people/:id/star/:type/:action_id' => 'people#star', :as => :star, :via => "post"
  match '/people/:id/tag/' => 'people#tag', :as => :new_tag, :via => "post"
  match '/people/:id/tag/:tag' => 'people#untag', :as => :untag, :via => "delete"

  root :to => 'index#dashboard', :constraints => lambda{|r| r.env["warden"].authenticate?}
  root :to => 'pages#index'
  match '/faq' => 'pages#faq'
  match '/pricing' => 'pages#pricing'
  match '/features' => 'pages#features'
  match '/updates' => 'pages#updates'
  match '/opensource' => 'pages#opensource'
  match '/contact' => 'pages#contact'
  match '/pages/tou' => 'pages#tou', :as => 'tou'
  match '/pages/user_agreement' => 'pages#user_agreement', :as => 'user_agreement'
  match '/pages/privacy' => 'pages#privacy', :as => 'privacy'
  match '/newsletter' => 'pages#newsletter', :as => 'newsletter'
  match '/newsletter-form' => 'pages#newsletter_form', :as => 'newsletter_form'
end
