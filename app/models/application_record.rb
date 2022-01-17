class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def price_format(revenue)
    revenue.round(2)
  end
end
