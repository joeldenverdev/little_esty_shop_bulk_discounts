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

  after_update :discount_validator
  after_create :discount_price_calculator
  after_create :discount_validator

  def discount_price_calculator
    self.update!(discounted_price: calculate_discounted_price)
  end

  def discount_validator
    if eligible_for_discount && discount_needs_update
      self.update!(discount: eligible_discount, discounted_price: calculate_discounted_price)
    end
  end

  def discount_needs_update
    eligible_discount != discount
  end

  def eligible_for_discount
    item.bulk_discounts.where('bulk_discounts.threshold <= ?', quantity).count > 0
  end

  def eligible_discount
    item.bulk_discounts
        .where('bulk_discounts.threshold <= ?', quantity)
        .select("discount")
        .order(discount: :desc)
        .pluck(:discount)
        .first || 0
  end

  def has_discount
    discount > 0
  end

  def bd_id
    item.bulk_discounts
        .where('bulk_discounts.discount = ?', discount)
        .select('bulk_discounts.id')
        .group("bulk_discounts.id")
        .pluck(:id)
        .first
  end

  def self.incomplete_invoices
    invoice_ids = InvoiceItem.where("status = 0 OR status = 1").pluck(:invoice_id)
    Invoice.order(created_at: :asc).find(invoice_ids)
  end
end
