class CreateTaxCalculators < ActiveRecord::Migration[7.0]
  def change
    create_table :tax_calculators do |t|
      t.string  :employee_name
      t.integer :annual_salary
      t.float :monthly_income_tax
      t.timestamps
    end
  end
end
