class InvoiceItem < ApplicationRecord
  validates_presence_of :invoice_id,
                        :item_id,
                        :quantity,
                        :unit_price,
                        :status

  belongs_to :invoice
  belongs_to :item
  has_many :merchants, through: :item

  enum status: [:pending, :packaged, :shipped]

  after_update :discount_checker
  after_create :default_price_calculator
  after_create :discount_checker

  def default_price_calculator
    self.update!(discounted_price: unit_price - (eligible_discount * (unit_price / 100.00)))
  end

  def discount_checker
    if check_for_discount_eligibility > 0 && discount_needs_update
      self.update!(discount: eligible_discount, discounted_price: (unit_price - (unit_price * (eligible_discount / 100.00))))
    end
  end

  def discount_needs_update
    eligible_discount != discount
  end

  def check_for_discount_eligibility
    item.bulk_discounts.where('bulk_discounts.threshold <= ?', quantity).count
  end

  def eligible_discount
    item.bulk_discounts
        .where('bulk_discounts.threshold <= ?', quantity)
        .select("discount")
        .order(discount: :desc)
        .pluck(:discount)
        .first || 0
  end

  def self.incomplete_invoices
    invoice_ids = InvoiceItem.where("status = 0 OR status = 1").pluck(:invoice_id)
    Invoice.order(created_at: :asc).find(invoice_ids)
  end
end
