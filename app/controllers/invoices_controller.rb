class InvoicesController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    # require 'pry'; binding.pry
    @invoices = @merchant.invoices.distinct
  end
  
  def show
    @invoice = Invoice.find(params[:id])
    @merchant = Merchant.find(params[:merchant_id])
  end

  def update
    @merchant = Merchant.find(params[:merchant_id])
    @invoice = Invoice.find(params[:id])
    @invoice.update({
      status: params[:invoice][:status]})
    
    redirect_to merchant_invoice_path(@merchant, @invoice)
  end
end