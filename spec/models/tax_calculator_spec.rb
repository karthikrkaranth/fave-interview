require 'rails_helper'

RSpec.describe TaxCalculatorController, type: :controller do
  describe "#generate_monthly_payslip" do
    context "with valid input" do
      it "returns the tax data" do
        post :generate_monthly_payslip, params: { employee_name: "Jane Smith", annual_salary: 60000 }
        expect(response).to have_http_status(:ok)

        tax_data = JSON.parse(response.body)

        expect(tax_data["employee_name"]).to eq("Jane Smith")
        expect(tax_data["monthly_income_tax"]).to eq("$500.0")
        expect(tax_data["gross_monthly_income"]).to eq("$5000.0")
        expect(tax_data["net_monthly_income"]).to eq("$4500.0")
      end
    end

    context "with invalid input" do
      it 'with invalid input returns an error message' do
        post :generate_monthly_payslip, params: { annual_salary: 'not a number', employee_name: '' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Invalid input')
      end

    end
  end

  describe "#save_tax_data" do
    it "saves the tax data to the database" do
      expect {
        subject.save_tax_data({
                                employee_name: "Jane Smith",
                                annual_salary: 75000,
                                monthly_income_tax: 6250
                              })
      }.to change(TaxCalculator, :count).by(1)
    end

    it "returns the calculated tax data" do
      tax_data = subject.save_tax_data({
                                         employee_name: "Jane Smith",
                                         annual_salary: 75000,
                                         monthly_income_tax: 750.0
                                       })

      expect(tax_data[:employee_name]).to eq("Jane Smith")
      expect(tax_data[:gross_monthly_income]).to eq("$6250.0")
      expect(tax_data[:monthly_income_tax]).to eq("$750.0")
      expect(tax_data[:net_monthly_income]).to eq("$5500.0")
    end
  end

end
