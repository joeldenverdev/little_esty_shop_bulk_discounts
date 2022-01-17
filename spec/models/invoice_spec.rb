require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many :transactions}
  end
  
  describe "instance methods" do
    it "total_revenue" do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)

      expect(@invoice_1.total_revenue).to eq(100)
    end
  end

  describe '#percent_discount' do
    it 'should return the percent(ages) of discount as integers for that invoice' do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @bd1 = @merchant1.bulk_discounts.create!(threshold: 10, discount: 10)
      @bd2 = @merchant1.bulk_discounts.create!(threshold: 15, discount: 15)
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 12, unit_price: 10, status: 2)
      @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)

      expect(@invoice_1.percent_discount).to eq([10])
    end
  end

  describe '#total_after_discount' do
    it 'should return the total discounts applied to the invoice' do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @bd1 = @merchant1.bulk_discounts.create!(threshold: 10, discount: 10)
      @bd2 = @merchant1.bulk_discounts.create!(threshold: 15, discount: 15)
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 12, unit_price: 10, status: 2)
      @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)

      expect(@invoice_1.total_after_discount).to eq(108)
    end
  end

  describe '#total_discount' do
    it 'should return the difference in total revenue and discounted revenue' do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @bd1 = @merchant1.bulk_discounts.create!(threshold: 10, discount: 10)
      @bd2 = @merchant1.bulk_discounts.create!(threshold: 15, discount: 15)
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 12, unit_price: 10, status: 2)
      @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)

      expect(@invoice_1.total_discount).to eq(12)
    end
  end

  context 'merchant A has one Bulk Discount of 20% off 10 items' do
    it 'Example 1: will not inadvertently count two different items towards a discount if 5 of each Item A and Item B are purchased' do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @bd1 = @merchant1.bulk_discounts.create!(threshold: 10, discount: 20)
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 5, unit_price: 10, status: 2)
      @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 5, unit_price: 10, status: 2)
      @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)

      expect(@invoice_1.total_discount).to eq(0)
    end

    it 'Example 2: will not inadvertently give a discount for one item to the other if only one qualifies' do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @bd1 = @merchant1.bulk_discounts.create!(threshold: 10, discount: 20)
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 10, unit_price: 10, status: 2)
      @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 5, unit_price: 10, status: 2)
      @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)
      # require 'pry'; binding.pry
      expect(@invoice_1.total_discount).to eq(20.0)
    end
  end

  context 'merchant A has two Bulk Discounts for 20% off 10 items and 30% off 15 items' do
    # Example 3
    describe 'and if 12 of Item A are ordered and 15 of Item B are ordered' do
      it 'will discount Item A at 20% off and Item B should be discounted at 30% off' do
        @merchant1 = Merchant.create!(name: 'Hair Care')
        @bd1 = @merchant1.bulk_discounts.create!(threshold: 10, discount: 20)
        @bd1 = @merchant1.bulk_discounts.create!(threshold: 15, discount: 30)
        @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
        @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
        @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
        @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 12, unit_price: 10, status: 2)
        @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 15, unit_price: 10, status: 2)
        @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)

        expect(@invoice_1.total_discount).to eq(69)

        expect(@ii_1.discount).to eq(20)
        expect(@ii_2.discount).to eq(30)
      end
    end
  end

  context 'merchant A has two Bulk Discounts' do
    describe 'and even though BD A is 20% off for 10 items and BD B is 15% off of 15 items' do
      it 'will choose the highest discount to be applied, in this case 20% for all items' do
        @merchant1 = Merchant.create!(name: 'Hair Care')
        @bd1 = @merchant1.bulk_discounts.create!(threshold: 10, discount: 20)
        @bd1 = @merchant1.bulk_discounts.create!(threshold: 15, discount: 15)
        @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
        @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 10, merchant_id: @merchant1.id)
        @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
        @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 12, unit_price: 10, status: 2)
        @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 15, unit_price: 10, status: 2)
        @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)

        expect(@invoice_1.total_discount).to eq(54)

        expect(@ii_1.discount).to eq(20)
        expect(@ii_2.discount).to eq(20)
      end
    end
  end

  # Example Scenario 5
  context 'merchant A has 2 bulk discounts of 20% and 30% off 10 and 15 items and Merchant B has no bulk discounts' do
    describe 'and Invoice A has two of Merchant As items and one of merchant Bs items' do
      it 'will discount Item A1 and A2 by 20% off and 30% off and Item B should not be discounted at all' do
        @merchant1 = Merchant.create!(name: 'Hair Care')
        @merchant2 = Merchant.create!(name: 'Skin Care')
        @bd1 = @merchant1.bulk_discounts.create!(threshold: 10, discount: 20)
        @bd1 = @merchant1.bulk_discounts.create!(threshold: 15, discount: 30)
        @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
        @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 10, merchant_id: @merchant1.id)
        @item_3 = Item.create!(name: "Lotion", description: "This moisturizes", unit_price: 10, merchant_id: @merchant2.id)
        @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
        @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 12, unit_price: 10, status: 2)
        @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 15, unit_price: 10, status: 2)
        @ii_3 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_3.id, quantity: 15, unit_price: 10, status: 2)
        @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)

        expect(@invoice_1.total_discount).to eq(69)
        expect(@ii_1.discount).to eq(20)
        expect(@ii_2.discount).to eq(30)
        expect(@ii_3.discount).to eq(0)
      end
    end
  end


end
