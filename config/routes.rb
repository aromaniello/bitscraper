Rails.application.routes.draw do
	root to: "bitcointalk_users#index"
	resources :bitcointalk_users, only: [:index, :show]
end
