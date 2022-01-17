class AddDiscountedPriceToInvoiceItems < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_items, :discounted_price, :float, default: 0.00
  end
end
