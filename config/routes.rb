Diffux::Application.routes.draw do
  get 'static_pages/about'

  resources :projects do
    resources :sweeps, only: %i[index show new create] do
      collection do
        post :trigger
      end
    end
  end
  resources :urls,      only: %i[destroy show]
  resources :viewports, only: %i[edit update]

  resources :snapshots, only: %i[show create destroy] do
    member do
      post :accept
      post :reject
      post :take_snapshot
    end
  end

  root to: 'projects#index'
end
