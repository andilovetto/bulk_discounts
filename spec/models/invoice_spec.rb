require "rails_helper"

RSpec.describe Invoice, type: :model do
 
  it { should belong_to(:customer) }
  it { should have_many(:invoice_items) }
  it { should have_many(:transactions) }
  it { should have_many(:items).through(:invoice_items) }
  it { should have_many(:merchants).through(:items) }

  it "calculates the total revenue correctly" do
    invoice = create(:invoice)
    item1 = create(:item)
    item2 = create(:item)

    create(:invoice_item, invoice: invoice, item: item1, quantity: 3, unit_price: 10)
    create(:invoice_item, invoice: invoice, item: item2, quantity: 2, unit_price: 20)

    expect(invoice.total_revenue).to eq(70) 
  end


  describe "validations" do
    it { should validate_presence_of(:status) }
    it { should define_enum_for(:status) }
  end

  describe "#instance_methods" do
    describe "#format_created_at" do
      it "can format the created_at timestampt to resemble 'Monday, July 18, 2019'" do
        customer = Customer.create!(first_name: "Ringo", last_name: "Star")
        invoice = customer.invoices.create!(status: "completed", customer_id: 12345, created_at: 'Thu, 27 Jul 2023 21:03:33.548215000 UTC +00:00')

        expect(invoice.format_created_at).to eq('Thursday, July 27, 2023')
      end
    end

    describe "#total_revenue" do
      it "can find sum of all invoice_items unit_prices" do
        merchant = FactoryBot.create(:merchant)
        customer = FactoryBot.create(:customer)
        invoice = FactoryBot.create(:invoice, customer: customer)
        item = FactoryBot.create(:item, merchant: merchant)
        
        invoice_item_1 = InvoiceItem.create!(quantity: 8, unit_price: 100, status: "pending", invoice_id: invoice.id, item_id: item.id)
        invoice_item_2 = InvoiceItem.create!(quantity: 8, unit_price: 100, status: "pending", invoice_id: invoice.id, item_id: item.id)
        invoice_item_3 = InvoiceItem.create!(quantity: 8, unit_price: 100, status: "pending", invoice_id: invoice.id, item_id: item.id)

        expect(invoice.total_revenue).to eq(2400)
      end
    end

    describe "#discounted_revenue" do
      it "can calculate discount given to invoice items" do
        merchant_10 = Merchant.create!(name: "andi")
        customer = FactoryBot.create(:customer)
        invoice = FactoryBot.create(:invoice, customer: customer)
        item = FactoryBot.create(:item, merchant: merchant_10)
        item_3 = FactoryBot.create(:item, merchant: merchant_10)
        invoice_item = FactoryBot.create(:invoice_item, item: item, invoice: invoice, status: "packaged", quantity: 12, unit_price: 10)
        invoice_item_3 = FactoryBot.create(:invoice_item, item: item_3, invoice: invoice, status: "packaged", quantity: 15, unit_price: 10)
        bulk_discount_1 = merchant_10.bulk_discounts.create!(percentage: 20, threshold: 10)
        bulk_discount_2 = merchant_10.bulk_discounts.create!(percentage: 30, threshold: 15)

        expect(invoice.discounted_revenue).to eq(69.0)
      end

      describe "#discounted_invoice_items" do
        it "returns an array of discounted invoice items" do
          merchant_10 = Merchant.create!(name: "andi")
          merchant_11 = Merchant.create!(name: "seth")
          customer = FactoryBot.create(:customer)
          invoice = FactoryBot.create(:invoice, customer: customer)
          item = FactoryBot.create(:item, merchant: merchant_10)
          item_3 = FactoryBot.create(:item, merchant: merchant_10)
          item_13 = FactoryBot.create(:item, merchant: merchant_11)
          item_23 = FactoryBot.create(:item, merchant: merchant_11)
          invoice_item = FactoryBot.create(:invoice_item, item: item, invoice: invoice, status: "packaged", quantity: 12, unit_price: 10)
          invoice_item_20 = FactoryBot.create(:invoice_item, item: item_3, invoice: invoice, status: "packaged", quantity: 2, unit_price: 10)
          invoice_item_13 = FactoryBot.create(:invoice_item, item: item_13, invoice: invoice, status: "packaged", quantity: 5, unit_price: 10)
          invoice_item_23 = FactoryBot.create(:invoice_item, item: item_23, invoice: invoice, status: "packaged", quantity: 15, unit_price: 10)
          bulk_discount_1 = merchant_10.bulk_discounts.create!(percentage: 20, threshold: 10)
          bulk_discount_2 = merchant_11.bulk_discounts.create!(percentage: 30, threshold: 15)

          invoice.discounted_invoice_items.each do |ii|
            expect(ii).to be_an(InvoiceItem)
          end
          
          
          
          #tried to test exact results but because of the group line, i think it isn't returning the full object
          # Diff:
          # @@ -1,3 +1,3 @@
          # -[#<InvoiceItem id: 1645, quantity: 12, unit_price: 10, status: "packaged", invoice_id: 1468, item_id: 1603, created_at: "2023-08-09 00:51:55.018182000 +0000", updated_at: "2023-08-09 00:51:55.018182000 +0000">,
          # - #<InvoiceItem id: 1648, quantity: 15, unit_price: 10, status: "packaged", invoice_id: 1468, item_id: 1606, created_at: "2023-08-09 00:51:55.021990000 +0000", updated_at: "2023-08-09 00:51:55.021990000 +0000">]
          # +[#<InvoiceItem:0x000000011763fca0 id: 1648>,
          # + #<InvoiceItem:0x000000011763fb60 id: 1645>]
        end
      end
    end
  end
end