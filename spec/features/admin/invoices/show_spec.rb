# spec/features/admin/invoices/show_spec.rb

require "rails_helper"

describe "Admin Invoices Show Page", :vcr do
  before :each do
    @m1 = Merchant.create!(name: "Merchant 1")
    @c1 = Customer.create!(first_name: "Lucifer", last_name: "Hell")

    @i1 = Invoice.create!(customer_id: @c1.id, status: 2, created_at: "2012-03-25 09:54:09")

    @item_1 = Item.create!(name: "socks", description: "for your feet", unit_price: 6, merchant_id: @m1.id)
    @item_2 = Item.create!(name: "shoes", description: "for your shoes", unit_price: 12, merchant_id: @m1.id)

    @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 12, unit_price: 2, status: 0)
    @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 6, unit_price: 1, status: 1)

    visit admin_invoice_path(@i1)
  end

  xit "should display the id, status, and created_at" do
    expect(page).to have_content("Invoice ##{Invoice.first.id}")
    expect(page).to have_content("Created on: #{Invoice.first.created_at.strftime("%A, %B %d, %Y")}")
  end

  xit "should display the customers name" do
    expect(page).to have_content("#{@c1.first_name} #{@c1.last_name}")
   
  end

  xit "should display all the items on the invoice" do
    expect(page).to have_content(@item_1.name)
    expect(page).to have_content(@item_2.name)

    expect(page).to have_content(@ii_1.quantity)
    expect(page).to have_content(@ii_2.quantity)

    expect(page).to have_content("$#{@ii_1.unit_price}")
    expect(page).to have_content("$#{@ii_2.unit_price}")

    expect(page).to have_content(@ii_1.status)
    expect(page).to have_content(@ii_2.status)
  end

  xit "should display the total revenue the invoice will generate" do
    expect(page).to have_content("Total Revenue: $#{'%.2f' % @i1.total_revenue}")
  end

  it "should have status as a select field that updates the invoice's status" do
    within("#status-update-#{Invoice.first.id}") do
      select("cancelled", :from => "invoice[status]")
      click_button "Update Invoice"

      expect(current_path).to eq(admin_invoice_path(Invoice.first))
      expect(Invoice.first.status).to eq("cancelled")
    end
  end
  
  it "displays total discounted revenue" do
    merchant_10 = Merchant.create!(name: "andi")
    merchant_11 = Merchant.create!(name: "seth")
    customer = FactoryBot.create(:customer)
    invoice = FactoryBot.create(:invoice, customer: customer)
    item = FactoryBot.create(:item, merchant: merchant_10)
    item_3 = FactoryBot.create(:item, merchant: merchant_10)
    item_13 = FactoryBot.create(:item, merchant: merchant_11)
    invoice_item = FactoryBot.create(:invoice_item, item: item, invoice: invoice, status: "packaged", quantity: 12, unit_price: 10)
    invoice_item_3 = FactoryBot.create(:invoice_item, item: item_3, invoice: invoice, status: "packaged", quantity: 15, unit_price: 10)
    invoice_item_13 = FactoryBot.create(:invoice_item, item: item_13, invoice: invoice, status: "packaged", quantity: 15, unit_price: 10)
    bulk_discount_1 = merchant_10.bulk_discounts.create!(percentage: 20, threshold: 10)
    bulk_discount_2 = merchant_10.bulk_discounts.create!(percentage: 30, threshold: 15)

    visit admin_invoice_path(invoice)
    
    within(".revenue") do
      expect(page).to have_content("Total Revenue: $420.00")
      expect(page).to have_content("Total Discounted Revenue: $351.00")
    end
  end
end