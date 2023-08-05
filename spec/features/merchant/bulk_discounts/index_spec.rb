require "rails_helper"

RSpec.describe "merchant's bulk discount index" do
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

    visit merchant_bulk_discounts_path(@merchant_1)
  end

  it "displays a merchant's bulk discounts with links to the show page" do
    expect(page).to have_content("Discount Percentage: #{@bulk_discount_1.percentage}")
    expect(page).to have_content("Discount Threshold: #{@bulk_discount_1.threshold}")
    expect(page).to have_content("Discount Percentage: #{@bulk_discount_2.percentage}")
    expect(page).to have_content("Discount Threshold: #{@bulk_discount_2.threshold}")
    expect(page).to have_content("Discount Percentage: #{@bulk_discount_3.percentage}")
    expect(page).to have_content("Discount Threshold: #{@bulk_discount_3.threshold}")
    expect(page).to_not have_content("Discount Percentage: #{@bulk_discount_4.percentage}")
    expect(page).to_not have_content("Discount Threshold: #{@bulk_discount_4.threshold}")
    expect(page).to have_link(@bulk_discount_1.threshold)
    click_link @bulk_discount_1.threshold
    expect(current_path).to eq(merchant_bulk_discount_path(@merchant_1, @bulk_discount_1))
  end

  it "has a link to create a new discount" do
    expect(page).to have_link("New Discount")
    click_link "New Discount"
    expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant_1))
  end
end