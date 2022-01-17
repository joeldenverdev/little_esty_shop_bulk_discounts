require 'rails_helper'

RSpec.describe BulkDiscount do
  describe 'validations' do
    it { should validate_presence_of :discount }
    it { should validate_presence_of :threshold }
    it { should validate_numericality_of :discount }
    it { should validate_numericality_of :threshold }
    # it { should define_enum_for(:status).with_values([:inactive, :active]) }
    # it { should discount_status_check(:discount_status_check) }
  end

  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many(:items).through(:merchant) }
  end

  # describe "callback method #discount_status_check" do
  #   it 'should change the status of the bulk discount to active when the threshold has been updated and met' do
  #     @merchant1 = Merchant.create!(name: 'Hair Care')
  #     @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
  #     @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
  #     @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
  #     @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
  #     @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 2)
  #     @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)
  #     @bd1 = @merchant1.bulk_discounts.create!(threshold: 10, discount: 10)
  #
  #     expect(@bd1.status).to eq("inactive")
  #
  #     @ii_1.update!(quantity: 11)
  #
  #     expect(@bd1.status).to eq("active")
  #   end
  # end
end
