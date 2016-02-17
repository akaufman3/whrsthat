Rails.application.routes.draw do
  
  get '/' => 'main#home'

  get '/about' => 'main#about'

  get '/contact' => 'main#contact'

  get '/login' => 'users#login'
  
  get '/logout' => 'users#logout'
  
  get '/event_photo' => 'event_photos_controller#index'
  
  get 'event_photos_controller/index'

  get 'event_photos_controller/new'

  get 'event_photos_controller/create'

  get 'event_photos_controller/destroy'
  
  post '/api/text/inbound' => 'invitees#text'
  
  get 'auth/:provider/callback', to: 'users#google_create'

  get 'auth/failure', to: redirect('/')

  # get 'signout', to: 'users#google_signout', as: 'signout'

  post '/login' => 'users#login'
  
  post '/events/:id/invite' => 'events#invite'
  
  
  delete '/events/:id/:invite_id' => 'events#invite_destroy'

  resources :invitees 
  
  resources :users, only: [ :new, :create, :destroy, :update]

  resources :events
  
  resources :event_photo, only: [:index, :new, :create, :destroy]

  resources :events do

  resources :event_photos
  
  end
  get '/event_photo' => 'event_photos_controller#index'

  get 'auth/:provider/callback', to: 'users#google_create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'users#google_signout', as: 'signout'
  post '/users/geo' => "users#geo"

  get '/rsvp/:id' => 'invitees#show'
  post '/rsvp/:id/respond' => 'invitees#respond'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
