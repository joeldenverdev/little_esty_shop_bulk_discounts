class BulkDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @bd = @merchant.bulk_discounts
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = @merchant.bulk_discounts.create!(bulk_discount_params)
    redirect_to merchant_bulk_discounts_path(@merchant)
  end

  def show
    @bd = BulkDiscount.find(params[:id])
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @bd = BulkDiscount.find(params[:id])
  end

  def update
    @bulk_discount = BulkDiscount.find(params[:id])
    if @bulk_discount.update(bulk_discount_params)
      flash.notice = "Successfully Updated the Bulk Discount!"
      redirect_to merchant_bulk_discount_path(params[:merchant_id], params[:id])
    else
      flash.notice = "The form must be completed!!"
      redirect_to edit_merchant_bulk_discount_path(params[:merchant_id], params[:id])
    end
  end

  def destroy
    bulk_discount = BulkDiscount.find(params[:id])
    bulk_discount.destroy
    redirect_to merchant_bulk_discounts_path(params[:merchant_id])
  end

private
  def bulk_discount_params
    params.permit(:discount, :threshold)
  end
end
