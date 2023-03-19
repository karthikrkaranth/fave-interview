Rails.application.routes.draw do
  get '/', to: 'tax_calculator#index'

  # Route for tax calculation
  post '/generate_monthly_payslip', to: 'tax_calculator#generate_monthly_payslip'
  get 'export_csv', to: 'tax_calculator#export_csv', defaults: { format: :csv }
  get '/get_salary_info', to: 'tax_calculator#get_salary_info'

end
