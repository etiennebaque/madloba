Madloba::Application.routes.draw do

  devise_for :user, path: 'user', path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', registration: 'register', sign_up: 'new' },
             controllers: { registrations: 'user/registrations'}

  # Home page
  get 'home/index'
  get 'search', to: 'home#index'

  # About page
  get 'about', to: 'home#about'

  # Setup pages
  get 'setup/language', to: 'setup#show_choose_language'
  post 'setup/language/process', to: 'setup#process_chosen_language'
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
    get '/', to: 'admin_panel#index'

    resources :locations, :categories, :items, :users
    resources :ads, :only => [:edit, :update, :destroy]

    get 'index', 'home', to: 'admin_panel#index'
    get 'managerecords', to: 'admin_panel#managerecords'
    get 'manageusers', to: 'admin_panel#manageusers'
    get 'manageads', to: 'admin_panel#manageads'
    get 'manageprofile', to: 'users#edit'
    get 'generalsettings', to: 'admin_panel#generalsettings'
    get 'mapsettings', to: 'admin_panel#mapsettings'
    get 'areasettings', to: 'admin_panel#areasettings'

    post 'mapsettings/update', to: 'admin_panel#update_mapsettings'
    post 'generalsettings/update', to: 'admin_panel#update_generalsettings'
    post 'areasettings/update', to: 'admin_panel#update_areasettings'
    post 'areasettings/update_districts', to: 'admin_panel#update_districts'

    get 'getAreaSettings', to: 'admin_panel#getAreaSettings'

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

  # Root
  root 'home#index'

end
