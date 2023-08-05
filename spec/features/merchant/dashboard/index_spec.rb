require "rails_helper"

RSpec.describe "merchant dashboards index", :vcr do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Schroeder-Jerde", status: nil)
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
  end
  
  describe "as a merchant" do
    describe "when I visit my merchant dashboard" do
      it "displays the name of my merchant" do
        visit merchant_dashboards_path(@merchant_1)

        expect(page).to have_content(@merchant_1.name)
      end

      #User Story 2
      it "I see a link to my merchant items index (/merchants/:merchant_id/items)" do
        visit merchant_dashboards_path(@merchant_1)
       
        expect(page).to have_link("My Items", href: merchant_items_path(@merchant_1.id))
      end

      it "And I see a link to my merchant invoices index (/merchants/:merchant_id/invoices)" do
        visit merchant_dashboards_path(@merchant_1)
     
        expect(page).to have_link("My Invoices", href: merchant_invoices_path(@merchant_1.id))
      end

       # User Story 3
      it "I see the names of the top 5 customers who have conducted the largest number of successful transactions with my merchant" do
        visit merchant_dashboards_path(@merchant_1)

        customers = @merchant_1.top_5_customers

        expect(page).to have_content("Favorite Customers")
        customers.each do |customer|
          expect(page).to have_content(customer.full_name)
        end
      end

      it "and next to each customer name I see the number of successful transactions they have conducted with my merchant" do
        visit merchant_dashboards_path(@merchant_1) 
      
        customers = @merchant_1.top_5_customers

        expect(page).to have_content("Favorite Customers")
        customers.each do |customer|
          expect(page).to have_content(customer.transaction_count)
        end
      end

      # User Story 4
      it "I see a section for 'Items Ready to Ship' that has a list of then names of all of my items that have been ordered and have not yet been shipped" do
        visit merchant_dashboards_path(@merchant_1)
        
        within("#ready-to-ship") do
          expect(page).to have_content("Items Ready To Ship")
        end
      end

      it "and next to each Item I see the id of the invoice that ordered my item, and each invoice id is a link to my merchant's invoice show page" do
        visit merchant_dashboards_path(@merchant_1)
        
        invoice_link = @merchant_1.ready_to_ship.first.invoice_id
        
        within("#ready-to-ship") do
          expect(page).to have_link(invoice_link)
          click_link invoice_link
        end

        expect(current_path).to eq(merchant_invoice_path(@merchant_1,invoice_link))
      end

      # User Story 5
      it "In the 'Items Ready To Ship' section, Next to each Item name I see the date that the invoice was created and I see the date formatted like 'Monday, July 18, 2019'" do
        visit merchant_dashboards_path(@merchant_1)
        
        invoice = @invoices.first

        expect(page).to have_content(invoice.format_created_at)
      end
    end

    describe "bulk discounts" do
      it "has a link to view all merchant discounts" do
        visit merchant_dashboards_path(@merchant_1)
        expect(page).to have_link("Discounts")
        click_link "Discounts"
        expect(current_path).to eq(merchant_bulk_discounts_path(@merchant_1))
      end
    end
  end
end
