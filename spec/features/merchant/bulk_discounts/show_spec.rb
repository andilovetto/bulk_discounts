require "rails_helper"

RSpec.describe "merchant's bulk discount show page" do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Schroeder-Jerde", status: nil)
    @merchant_2 = Merchant.create!(name: "bob the drag queen", status: nil)
    @items = create_list(:item, 20, merchant: @merchant_1)
  
    # Create invoices and associate with items
    @invoices = create_list(:invoice, 20)
    @invoice_items = @invoices.map do |invoice|
      create(:invoice_item, item: @items.sample, invoice: invoice)
    end
  
    # Create customers and associate them with random invoices
    @customers = create_list(:customer, 10)
    @invoices.each do |invoice|
      invoice.update(customer: @customers.sample)
    end
  
    @transactions = @invoices.map do |invoice|
      create(:transaction, invoice: invoice, result: 0)
    end

    @bulk_discount_1 = @merchant_1.bulk_discounts.create!(percentage: 20, threshold: 10)
    @bulk_discount_2 = @merchant_1.bulk_discounts.create!(percentage: 10, threshold: 5)
    @bulk_discount_3 = @merchant_1.bulk_discounts.create!(percentage: 30, threshold: 15)
    @bulk_discount_4 = @merchant_2.bulk_discounts.create!(percentage: 70, threshold: 2)

    visit merchant_bulk_discount_path(@merchant_1, @bulk_discount_1)

  end
  
  it "displays a bulk discount's quantity threshold and percentage discount" do
    expect(page).to have_content(@bulk_discount_1.percentage)
    expect(page).to have_content(@bulk_discount_1.threshold)
    expect(page).to_not have_content(@bulk_discount_3.percentage)
    expect(page).to_not have_content(@bulk_discount_3.threshold)
  end

  it "has a link to edit a bulk discount" do
    expect(page).to have_button("Edit")
    click_button "Edit"
    expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant_1, @bulk_discount_1))
  end
end