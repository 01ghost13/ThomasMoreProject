Rails.application.routes.draw do
  #Concerns
  concern :group_result do
    resources :result_of_tests, only: [:index], path: 'results', param: :result_id
  end
  
  #Routes
  root 'sessions#new'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  resources :interests, only: [:index, :destroy] do
    collection do
      post 'new' => 'interests#create'
      get 'new' => 'interests#index'
      patch 'update' => 'interests#update'
      get 'update' => 'interests#index'
    end
  end
  resources :administrators, concerns: :group_result 
  resources :tutors, concerns: :group_result 
  resources :students, concerns: :group_result do
    member do
      get 'tests' => 'tests#index', as: 'tests'
      get 'tests/:test_id/testing' => 'tests#testing', as: 'testing'
      get 'tests/:test_id/testing/update_picture' => 'tests#update_picture'
      post 'tests/:test_id/testing/exit' => 'tests#exit'
      get 'edit/update_tutors' => 'students#update_tutors'
    end 
    resources :result_of_tests, except: [:new,:create,:index], path: 'results', param: :result_id
    get 'update_tutors' => 'students#update_tutors', on: :new
  end
  resources :tests, except:[:index]

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
