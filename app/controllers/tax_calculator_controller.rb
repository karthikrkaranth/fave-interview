require 'axlsx'

class TaxCalculatorController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:generate_monthly_payslip, :get_salary_info]

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

  def export_csv
    tax_calculators = TaxCalculator.select(:created_at, :employee_name, :annual_salary, :monthly_income_tax)
    salary_computations = tax_calculators.map do |tc|
      {
        time_stamp: tc.created_at.to_s,
        employee_name: tc.employee_name,
        annual_salary: tc.annual_salary.to_s,
        monthly_income_tax: tc.monthly_income_tax.to_s
      }
    end
    package = Axlsx::Package.new
    workbook = package.workbook
    workbook.add_worksheet(name: "Salary Computations") do |sheet|
      sheet.add_row ["Created At", "Employee Name", "Annual Salary", "Monthly Income Tax"]
      salary_computations.each do |sc|
        sheet.add_row [sc[:time_stamp], sc[:employee_name], sc[:annual_salary], sc[:monthly_income_tax]]
      end
    end

    filename = "salary_computations_#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.csv"
    send_data package.to_stream.read, filename: filename

  end

  def get_salary_info
    tax_calculators = TaxCalculator.select(:created_at, :employee_name, :annual_salary, :monthly_income_tax)
    salary_computations = tax_calculators.map do |tc|
      {
        time_stamp: tc.created_at.to_s,
        employee_name: tc.employee_name,
        annual_salary: tc.annual_salary.to_s,
        monthly_income_tax: tc.monthly_income_tax.to_s
      }
    end
    render json: { salary_computations: salary_computations }
  end
end