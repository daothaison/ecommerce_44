Rails.application.routes.draw do
  root "static_pages#home"
  get "/contact", to: "contact#new"
end
