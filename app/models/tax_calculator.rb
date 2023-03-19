class TaxCalculator < ApplicationRecord
  include SingletonInstance

  # define the tax bracket rates and ranges in arrays
  TAX_BRACKET_RATES = [0.0, 0.1, 0.2, 0.3, 0.4]
  TAX_BRACKET_RANGES = [
    (0..20000),
    (20001..40000),
    (40001..80000),
    (80001..180000),
    (180001..Float::INFINITY)
  ]

  def generate_monthly_payslip(salary)
    taxable_amount = 0

    # iterate through each tax bracket range and calculate taxable amount
    TAX_BRACKET_RANGES.each_with_index do |range, i|
      if salary > range.last
        taxable_amount += (range.last - range.first + 1) * TAX_BRACKET_RATES[i]
      elsif salary >= range.first
        taxable_amount += (salary - range.first + 1) * TAX_BRACKET_RATES[i]
        break
      end
    end

    return taxable_amount
  end

end
