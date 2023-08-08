require "rails_helper"

RSpec.describe "merchant invoice show page", :vcr do
  before(:each) do
    @merchant = FactoryBot.create(:merchant)
    @customer = FactoryBot.create(:customer)
    @invoice = FactoryBot.create(:invoice, customer: @customer)
    @item = FactoryBot.create(:item, merchant: @merchant)
    @item_3 = FactoryBot.create(:item, merchant: @merchant)
    @invoice_item = FactoryBot.create(:invoice_item, item: @item, invoice: @invoice, status: "packaged", quantity: 10, unit_price: 10)
    @invoice_item_3 = FactoryBot.create(:invoice_item, item: @item_3, invoice: @invoice, status: "packaged", quantity: 8, unit_price: 10)
    @bulk_discount_1 = @merchant.bulk_discounts.create!(percentage: 20, threshold: 10)


    @merchant_2 = FactoryBot.create(:merchant)
    @customer_2 = FactoryBot.create(:customer)
    @invoice_2 = FactoryBot.create(:invoice, customer: @customer_2)
    @item_2 = FactoryBot.create(:item, merchant: @merchant_2)
    @invoice_item_2 = FactoryBot.create(:invoice_item, item: @item_2, invoice: @invoice_2, status: "shipped")
  end

  describe "as a merchant" do
    describe "when I visit my merchant's invoice show page (/merchants/:merchant_id/invoices/:invoice_id)" do
      # User Story 15
      it "then I see information related to that invoice including: Invoice id, Invoice status, Invoice created_at in the format 'Monday, July 18, 2019', customer first and last name" do
        visit merchant_invoice_path(@merchant, @invoice)

        expect(page).to have_content(@invoice.id)
        expect(page).to have_content(@invoice.status)
        expect(page).to have_content(@invoice.format_created_at) 
        expect(page).to have_content(@customer.first_name)
        expect(page).to have_content(@customer.last_name)
      end

      # User Story 16
      it "then I see all of my items on the invoice including: Item name, the quantity of the item ordered, the price the Item sold for, the Invoice Item status, and I do not see any information related to Items for other merchants" do
        visit merchant_invoice_path(@merchant, @invoice)

        expect(page).to have_content(@item.name)
        expect(page).to have_content(@invoice_item.quantity)
        expect(page).to have_content(@invoice_item.format_price) 
        expect(page).to have_content(@invoice_item.status)

        expect(page).to_not have_content(@item_2.name)
        expect(page).to_not have_content(@invoice_item_2.format_price)
        expect(page).to_not have_content(@invoice_item_2.status)
      end

      # User Story 17
      it "then I see the total revenue that will be generated from all of my items on the invoice" do
        visit merchant_invoice_path(@merchant, @invoice)

        expect(page).to have_content(@invoice.total_revenue)
      end

      # User Story 18
      it "I see that each invoice item status is a select field and I see that the invoice item's current status is selected" do
        visit merchant_invoice_path(@merchant, @invoice)

        within("#status-update-#{@invoice.id}") do
          expect(page).to have_select("invoice[status]")
          expect(page).to have_select("invoice[status]", selected: @invoice.status)
        end
      end

      it "when I click this select field, then I can select a new status for the item, and next to the select field I see a button to 'Update Item Status'," do
        visit merchant_invoice_path(@merchant, @invoice)
      
        within("#status-update-#{@invoice.id}") do
          select "completed"
          expect(page).to have_button("Update Invoice")
        end
      end
    
      it "when I click this button, I am taken back to the merchant invoice show page and I see that my Item's status has now been updated" do
        visit merchant_invoice_path(@merchant, @invoice)

        within("#status-update-#{@invoice.id}") do
          select "completed"
          click_on "Update Invoice"
          expect(current_path).to eq(merchant_invoice_path(@merchant, @invoice))
        end
      end

      it "displays total revenue for a merchant with bulk discount applied" do
        visit merchant_invoice_path(@merchant, @invoice)

        expect(page).to have_content("Total Revenue: $180.00")
        expect(page).to have_content("Total Discounted Revenue: $160.00")
      end

      it "passes example 1" do
        merchant = FactoryBot.create(:merchant)
        customer = FactoryBot.create(:customer)
        invoice = FactoryBot.create(:invoice, customer: customer)
        item = FactoryBot.create(:item, merchant: merchant)
        item_3 = FactoryBot.create(:item, merchant: merchant)
        invoice_item = FactoryBot.create(:invoice_item, item: item, invoice: invoice, status: "packaged", quantity: 5, unit_price: 10)
        invoice_item_3 = FactoryBot.create(:invoice_item, item: item_3, invoice: invoice, status: "packaged", quantity: 5, unit_price: 10)
        bulk_discount_1 = merchant.bulk_discounts.create!(percentage: 20, threshold: 10)

        visit merchant_invoice_path(merchant, invoice)

        expect(page).to have_content("Total Revenue: $100.00")
        expect(page).to have_content("Total Discounted Revenue: $100.00")
      end

      it "passes example 2" do
        merchant = FactoryBot.create(:merchant)
        customer = FactoryBot.create(:customer)
        invoice = FactoryBot.create(:invoice, customer: customer)
        item = FactoryBot.create(:item, merchant: merchant)
        item_3 = FactoryBot.create(:item, merchant: merchant)
        invoice_item = FactoryBot.create(:invoice_item, item: item, invoice: invoice, status: "packaged", quantity: 10, unit_price: 10)
        invoice_item_3 = FactoryBot.create(:invoice_item, item: item_3, invoice: invoice, status: "packaged", quantity: 5, unit_price: 10)
        bulk_discount_1 = merchant.bulk_discounts.create!(percentage: 20, threshold: 10)

        visit merchant_invoice_path(merchant, invoice)

        expect(page).to have_content("Total Revenue: $150.00")
        expect(page).to have_content("Total Discounted Revenue: $130.00")
      end

      it "passes example 3" do
        merchant_10 = Merchant.create!(name: "andi")
        customer = FactoryBot.create(:customer)
        invoice = FactoryBot.create(:invoice, customer: customer)
        item = FactoryBot.create(:item, merchant: merchant_10)
        item_3 = FactoryBot.create(:item, merchant: merchant_10)
        invoice_item = FactoryBot.create(:invoice_item, item: item, invoice: invoice, status: "packaged", quantity: 12, unit_price: 10)
        invoice_item_3 = FactoryBot.create(:invoice_item, item: item_3, invoice: invoice, status: "packaged", quantity: 15, unit_price: 10)
        bulk_discount_1 = merchant_10.bulk_discounts.create!(percentage: 20, threshold: 10)
        bulk_discount_2 = merchant_10.bulk_discounts.create!(percentage: 30, threshold: 15)

        visit merchant_invoice_path(merchant_10, invoice)

        expect(page).to have_content("Total Revenue: $270.00")
        expect(page).to have_content("Total Discounted Revenue: $201.00")
      end

      it "passes example 4" do
        merchant_10 = Merchant.create!(name: "andi")
        customer = FactoryBot.create(:customer)
        invoice = FactoryBot.create(:invoice, customer: customer)
        item = FactoryBot.create(:item, merchant: merchant_10)
        item_3 = FactoryBot.create(:item, merchant: merchant_10)
        invoice_item = FactoryBot.create(:invoice_item, item: item, invoice: invoice, status: "packaged", quantity: 12, unit_price: 10)
        invoice_item_3 = FactoryBot.create(:invoice_item, item: item_3, invoice: invoice, status: "packaged", quantity: 15, unit_price: 10)
        bulk_discount_1 = merchant_10.bulk_discounts.create!(percentage: 20, threshold: 10)
        bulk_discount_2 = merchant_10.bulk_discounts.create!(percentage: 15, threshold: 15)

        visit merchant_invoice_path(merchant_10, invoice)

        expect(page).to have_content("Total Revenue: $270.00")
        expect(page).to have_content("Total Discounted Revenue: $216.00")

      end

      it "passes example 5" do
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

        visit merchant_invoice_path(merchant_10, invoice)

        expect(page).to have_content("Total Revenue: $420.00")
        expect(page).to have_content("Total Discounted Revenue: $351.00")
      end

    end
  end
end