require 'rails_helper' 

RSpec.describe "merchant dashboard", type: :feature do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Schroeder-Jerde", status: nil)
    @items = create_list(:item, 20, merchant: @merchant_1)
  
    # Create invoices with status = 2 and associate with items
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
       
        expect(page).to have_link("My Items", href: merchant_items_path(@merchant_1))
      end

      it "And I see a link to my merchant invoices index (/merchants/:merchant_id/invoices)" do
        visit merchant_dashboards_path(@merchant_1)
     
        expect(page).to have_link("My Invoices", href: merchant_invoices_path(@merchant_1))
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
    end
  end
end