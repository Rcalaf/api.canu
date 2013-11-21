CanuApi::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  resources :users 
  match 'users/:user_id/activities/' => 'users#activities', :via => :get
  match 'users/:user_id/activities/' => 'activities#create', :via => :post
  match 'users/:user_id/profile-image' => 'users#update_profile_pic', :via => :put
  match 'users/:user_id/device_token' => 'users#set_device_token', :via => :post
  match 'users/:user_id/activities/:activity_id' => 'activities#update', :via => :put
  match 'users/:user_id/activities/:activity_id' => 'activities#destroy', :via => :delete
  
  resources :activities
  match 'activities/:activity_id/attendees' => 'activities#attendees', :via => :get
  match 'activities/:activity_id/users/:user_id/attend' => 'activities#add_to_schedule', :via => :post
  match 'activities/:activity_id/users/:user_id/attend' => 'activities#remove_from_schedule', :via => :delete
  
  match 'activities/:activity_id/chat' => 'messages#messages', :via => :get
  match 'activities/:activity_id/chat' => 'messages#create', :via => :post
  
  match 'devices/:device_token/badge' => 'devices#edit_badge', :via => :put
  
 # namespace :session do 
  match 'session/' => 'session#user', :as => 'get_user', :via => :post
  match 'session/login/' => 'session#login', :as => 'login', :via => :post
  match 'session/logout/' => 'session#logout', as: 'logout', :via => :post
    
#  end
#  match 'users/' => 'users#create', :as => :user, :method => :post
#  match 'users/' => 'users#index', :as => :user, :method => :get
  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
