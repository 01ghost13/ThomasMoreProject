Rails.application.routes.draw do

  # Login pages
  devise_for :users

  #Concerns
  concern :group_result do
    resources :result_of_tests, only: [:index], path: 'results', param: :result_id
  end

  #Routes
  root 'static_pages#home'

  #Static pages
  # get 'about' => 'static_pages#about'
  # get 'contacts' => 'static_pages#contacts'
  get 'home' => 'static_pages#home'

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

  #...Mentors
  resources :mentors, concerns: :group_result do
    member do
      get 'delete' => 'mentors#delegate'
      delete 'delete' => 'mentors#delete'
    end
  end

  #...Clients
  resources :clients, concerns: :group_result do
    member do
      #Adding testing pages
      get 'tests' => 'testing_process#index', as: 'tests'
      get 'edit/update_mentors' => 'clients#update_mentors'
      get 'mode_settings' => 'clients#mode_settings'
      patch 'mode_settings' => 'clients#update_mode_settings'
    end
    resources :result_of_tests, except: [:new, :create, :index], path: 'results', param: :result_id
    get 'results/:result_id/heatmap'=> 'result_of_tests#show_heatmap', as: 'heatmap'
    get 'update_mentors' => 'clients#update_mentors', on: :new
  end

  scope '/testing_process' do
    get ':result_of_test_id/testing' => 'testing_process#testing', as: 'testing'
    post ':result_of_test_id/answer' => 'testing_process#answer', as: 'testing_answer'
    post 'clients/:id/tests/:test_id/start' => 'testing_process#begin', as: 'testing_begin'
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

  # Translations
  resources :translations, only: %i[index update create] do
    collection do
      post :translated_columns, to: 'translations#create_translated_columns'
      patch 'translated_columns/:id', to: 'translations#update_translated_columns'
      post :create_language, to: 'translations#create_language'
    end
  end
end
