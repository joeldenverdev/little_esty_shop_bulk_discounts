class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def calculate_discounted_price
    (unit_price - (unit_price * (eligible_discount / 100.00)))
  end
end
