Diffux::Application.routes.draw do
  get 'static_pages/about'

  resources :projects
  resources :urls, only: %i[destroy]

  resources :snapshots, only: %i[show create destroy] do
    member do
      post :accept
      post :reject
    end
  end

  root to: 'projects#index'
end
