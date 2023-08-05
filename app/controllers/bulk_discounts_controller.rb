class BulkDiscountsController < ApplicationController
  before_action :find_merchant
  
  def index
  end

  def show
    #you dont have to do shit here thanks to that friendly before action
  end

  def new
  end

  def create
    new_discount = @merchant.bulk_discounts.new(
      percentage: params[:percentage], 
      threshold: params[:threshold]
    )    
    new_discount.save 
    redirect_to merchant_bulk_discounts_path(@merchant)
  end

  def destroy
    #three steps to complete this task, what are they?
    bulk_discount_delete = BulkDiscount.find(params[:id])
    bulk_discount_delete.destroy
    redirect_to merchant_bulk_discounts_path(@merchant)
  end

  private
  
  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end