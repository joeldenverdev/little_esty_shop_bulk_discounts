class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  enum status: [:cancelled, 'in progress', :complete]

  def percent_discount
    invoice_items.where('discount != ?', 0).pluck(:discount)
  end

  def total_after_discount
    invoice_items.sum("discounted_price * quantity")
  end

  def total_discount
    total = invoice_items.sum("(unit_price * quantity) - (discounted_price * quantity)")
    total.round(2)
  end

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end
end
