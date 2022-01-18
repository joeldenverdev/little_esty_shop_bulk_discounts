require 'rails_helper'

RSpec.describe 'Bulk Discounts Edit Page and Form' do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')

    @bd1 = @merchant1.bulk_discounts.create!(threshold: 10, discount: 10)
    @bd2 = @merchant1.bulk_discounts.create!(threshold: 15, discount: 15)
    @bd3 = @merchant1.bulk_discounts.create!(threshold: 20, discount: 20)
  end

  context 'when I visit the bulk discounts show page' do
    describe 'and I click on the button to edit the discount information' do
      it 'has a link to edit that bulk discounts information' do
        visit  merchant_bulk_discount_path(@merchant1, @bd1)
        click_link "Edit Discount ##{@bd1.id}"

        expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant1, @bd1))

        fill_in :discount, with: 13
        fill_in :threshold, with: 13
        click_button "Submit"

        expect(current_path).to eq(merchant_bulk_discount_path(@merchant1, @bd1))

        expect(page).to have_content("Discount: 13%")
        expect(page).to have_content("Threshold: 13 Items")

        expect(page).to_not have_content("Discount: 10%")
        expect(page).to_not have_content("Threshold: 10 Items")
      end

      it 'has fields which are pre-filled with the existing discount info' do
        visit merchant_bulk_discount_path(@merchant1, @bd1)

        click_link "Edit Discount ##{@bd1.id}"

        expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant1, @bd1))

        expect(find_field('Discount').value).to eq("10")
        expect(find_field('Threshold').value).to eq("10")
      end

      # EDGE CASE / Extra Testing Scenarios
      it 'will always be up to date after repeated updates' do
        visit merchant_bulk_discount_path(@merchant1, @bd1)

        click_link "Edit Discount ##{@bd1.id}"

        expect(find_field('Discount').value).to eq("10")
        expect(find_field('Threshold').value).to eq("10")

        fill_in :discount, with: 13
        fill_in :threshold, with: 13
        click_button "Submit"

        # User has returned to show page
        click_link "Edit Discount ##{@bd1.id}"

        expect(find_field('Discount').value).to eq("13")
        expect(find_field('Threshold').value).to eq("13")

        fill_in :discount, with: 17
        fill_in :threshold, with: 17
        click_button "Submit"

        expect(page).to have_content("Discount: 17%")
        expect(page).to have_content("Threshold: 17 Items")

        expect(page).to_not have_content("Discount: 10%")
        expect(page).to_not have_content("Threshold: 10 Items")

        expect(page).to_not have_content("Discount: 13%")
        expect(page).to_not have_content("Threshold: 13 Items")
      end
      # EDGE CASE
      it 'allows the user to only change one attribute' do
        visit merchant_bulk_discount_path(@merchant1, @bd1)

        click_link "Edit Discount ##{@bd1.id}"

        expect(find_field('Discount').value).to eq("10")
        expect(find_field('Threshold').value).to eq("10")

        # Only choosing to update one field
        fill_in :threshold, with: 13
        click_button "Submit"

        expect(page).to have_content("Discount: 10%")
        expect(page).to have_content("Threshold: 13 Items")
      end

      context 'Edge Cases in which the user could break the form' do
        # EDGE CASE
        it 'will return an error message if the user tries to save the form with an empty field' do
          visit merchant_bulk_discount_path(@merchant1, @bd1)

          click_link "Edit Discount ##{@bd1.id}"

          expect(find_field('Discount').value).to eq("10")
          expect(find_field('Threshold').value).to eq("10")

          # Only choosing to update one field
          fill_in :threshold, with: ""
          fill_in :discount, with: ""
          click_button "Submit"

          expect(page).to have_content("The form must be completed!!")
        end
      end
    end
  end
end
