class BulkDiscountsController < ApplicationController
  before_action :find_merchant
  before_action :find_discount, only: [:show, :destroy, :edit, :update]


  
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

  def destroy
    @bulk_discount.destroy
    redirect_to merchant_bulk_discounts_path(@merchant)
  end

  def edit
  end

  def update
    @bulk_discount.update(discount_params)
    redirect_to merchant_bulk_discount_path(@merchant, @bulk_discount)
  end

  private
  
  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end

  def find_discount
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def discount_params
    params.require(:bulk_discount).permit(:threshold, :percentage)
  end
end