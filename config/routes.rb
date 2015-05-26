Madloba::Application.routes.draw do

  devise_for :user, path: 'user', path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', registration: 'register', sign_up: 'new' },
             controllers: { registrations: 'user/registrations', sessions: 'user/sessions', passwords: 'user/passwords', confirmations: 'user/confirmations' }

  # Home page
  get 'home/index'
  get 'search', to: 'home#index'

  # About page
  get 'about', to: 'home#about'

  # Setup pages
  get 'setup', to: 'setup#show_welcome'
  get 'setup/general', to: 'setup#show_general'
  post 'setup/general/process', to: 'setup#process_general'
  get 'setup/map', to: 'setup#show_map'
  post 'setup/map/process', to: 'setup#process_map'
  get 'setup/image', to: 'setup#show_image'
  post 'setup/image/process', to: 'setup#process_image'
  get 'setup/admin', to: 'setup#show_admin'
  post 'setup/admin/process', to: 'setup#process_admin'
  get 'setup/done', to: 'setup#show_finish'

  # Redirection to custom error screens
  match '/404' => 'errors#error404', via: [ :get, :post, :patch, :delete ]
  match '/500' => 'errors#error500', via: [ :get, :post, :patch, :delete ]

  namespace :user do
    get '/', to: 'base#index'

    resources :locations, :categories, :items, :users
    resources :ads, :only => [:edit, :update, :destroy]

    get 'index', 'home', to: 'base#index'
    get 'managerecords', to: 'base#managerecords'
    get 'manageusers', to: 'base#manageusers'
    get 'manageads', to: 'base#manageads'
    get 'manageprofile', to: 'users#edit'
    get 'generalsettings', to: 'base#generalsettings'
    get 'mapsettings', to: 'base#mapsettings'
    get 'areasettings', to: 'base#areasettings'

    post 'mapsettings/update', to: 'base#update_mapsettings'
    post 'generalsettings/update', to: 'base#update_generalsettings'
    post 'areasettings/update', to: 'base#update_areasettings'
    post 'areasettings/update_districts', to: 'base#update_districts'

    get 'getAreaSettings', to: 'base#getAreaSettings'

    get 'ads/:id/edit', to: 'ads#edit'

    # This POST method is called when the deletion of a category is made through a form
    post 'categories/:id', to: 'categories#destroy'

  end

  resources :ads, :only => [:show, :index, :new, :create], :controller => 'user/ads'
  post 'ads/send_message', to: 'user/ads#send_message'

  # Ajax calls to get details about a location (geocodes, exact address)
  get '/getCityGeocodes', to: 'application#getCityGeocodes'
  get '/getNominatimLocationResponses', to: 'application#getNominatimLocationResponses'

  # Ajax call to get the list of items, for autocomplete, when searching for an item, or creating/editing an ad.
  get '/getItems', to: 'application#get_items'

  # Ajax call to show the ads related to 1 type of item and to 1 district/area.
  get '/showSpecificAds', to: 'home#showSpecificAds'


  root 'home#index'

end
