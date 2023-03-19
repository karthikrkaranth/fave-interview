require 'axlsx'

class TaxCalculatorController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:generate_monthly_payslip]

  def index
    # Render the tax calculator form
  end

  def generate_monthly_payslip
    # Calculate tax based on form input
    salary = params[:annual_salary].to_i
    name = params[:employee_name]
    if !name || name == "" || !salary || salary <= 0
      render json: { error: 'Invalid input' }, status: :unprocessable_entity
    else
      tax = TaxCalculator.instance.generate_monthly_payslip(salary)
      tax_data = {
        employee_name: name,
        monthly_income_tax: tax / 12.0,
        annual_salary: salary
      }
      data = save_tax_data(tax_data)
      render json: data
    end

  end

  def save_tax_data(tax_data = {})
    # Save tax data to database
    TaxCalculator.create(tax_data)

    employee_name = tax_data[:employee_name]
    annual_salary = tax_data[:annual_salary]
    gross_monthly_income = (annual_salary / 12.0).round(2)
    monthly_income_tax = (TaxCalculator.instance.generate_monthly_payslip(annual_salary) / 12.0).round(2)
    net_monthly_income = (gross_monthly_income - monthly_income_tax).round(2)

    # create a hash with the required fields
    data = {
      employee_name: employee_name,
      gross_monthly_income: "$#{(annual_salary / 12.0).round(2)}", # monthly or yearly salary paid to an employee without any tax deductions
      monthly_income_tax: "$#{(monthly_income_tax).round(2)}",
      net_monthly_income: "$#{net_monthly_income}"
    }

     return data
  end

  def download_excel
    # Fetch data from the database
    @users = TaxCalculator.all

    # Create a new Excel workbook
    workbook = Axlsx::Package.new
    workbook.workbook.add_worksheet(name: "Users") do |sheet|
      # Add a header row
      sheet.add_row ["Name", "Annual Salary", "Monthly Income tax", "Created At"]
      # Add data for each user
      @users.each do |user|
        sheet.add_row [user.employee_name, user.annual_salary, user.monthly_income_tax, user.created_at]
      end
    end

    # Set the filename for the downloaded file
    filename = "users-#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.xlsx"

    # Send the file to the user as an attachment
    send_data workbook.to_stream.read, filename: filename, type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end
end