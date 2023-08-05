class BulkDiscountsController < ApplicationController
  before_action :find_merchant
  
  def index
  end

  def show
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

  private
  
  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end