Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  # Route for tax calculator form
  get '/', to: 'tax_calculator#index'

  # Route for tax calculation
  post '/generate_monthly_payslip', to: 'tax_calculator#generate_monthly_payslip'
  get 'download_excel', to: 'tax_calculator#download_excel', defaults: { format: :xlsx }

end
