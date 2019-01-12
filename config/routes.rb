Rails.application.routes.draw do

  #Concerns
  concern :group_result do
    resources :result_of_tests, only: [:index], path: 'results', param: :result_id
  end

  #Routes
  #Login pages
  root 'sessions#new'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  #Static pages
  get 'about' => 'static_pages#about'
  get 'contacts' => 'static_pages#contacts'

  #Pages for working with emails
  get 'confirmation_email' => 'mail#confirmation_email'
  get 'send_confirmation_again' => 'mail#send_confirmation_again'

  #form for reset password
  get 'reset_password' => 'mail#reset_password'
  post 'reset_password' => 'mail#submit_reset_password'

  #form for sending reset-link to email
  get 'forgot_password' => 'mail#forgot_password'
  post 'forgot_password' => 'mail#submit_forgot_password'

  #Interests pages
  resources :interests, only: [:index, :destroy]
  resources :interests, only: [] do
    collection do
      #Adding create and update routes to index page
      post '' => 'interests#create'
      patch '' => 'interests#update'
    end
  end

  #User pages...
  #...Administrators
  resources :administrators, concerns: :group_result  do
    member do
      get 'delete' => 'administrators#delegate'
      delete 'delete' => 'administrators#delete'
    end
  end
  #...Tutors
  resources :tutors, concerns: :group_result do
    member do
      get 'delete' => 'tutors#delegate'
      delete 'delete' => 'tutors#delete'
    end
  end
  #...Students
  resources :students, concerns: :group_result do
    member do
      #Adding testing pages
      get 'tests' => 'tests#index', as: 'tests'
      get 'tests/:test_id/testing' => 'tests#testing', as: 'testing'
      post 'tests/:test_id/testing/update_picture' => 'tests#update_picture'
      get 'edit/update_tutors' => 'students#update_tutors'
    end
    resources :result_of_tests, except: [:new, :create, :index], path: 'results', param: :result_id
    get 'update_tutors' => 'students#update_tutors', on: :new
  end

  #Tests pages
  resources :tests do
    get 'update_image' => 'tests#update_image', on: :new
    member do
      get 'edit/update_image' => 'tests#update_image'
    end
  end

  #Picture pages
  resources :pictures, except: [:show]
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
