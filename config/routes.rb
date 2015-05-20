Rails.application.routes.draw do
  scope :location_picker, module: :location_picker do
    resources :locations, only: [:create], constraints: { format: 'json' }
  end
end