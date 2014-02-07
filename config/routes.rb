Diffux::Application.routes.draw do
  get 'static_pages/about'

  resources :projects do
    resources :sweeps, only: %i[index show new create]
  end
  resources :urls, only: %i[destroy]

  resources :snapshots, only: %i[show create destroy] do
    member do
      post :accept
      post :reject
    end
  end

  root to: 'projects#index'
end
