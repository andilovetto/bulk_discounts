require "rails_helper"

RSpec.describe Item, type: :model do
  describe "relationships" do
    it { should belong_to(:merchant) }
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should have_many(:customers).through(:invoices) }
    it { should have_many(:transactions).through(:invoices) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_numericality_of(:unit_price) }
    it { should define_enum_for(:status) }
  end

  describe "#instance_methods" do
    describe "#formatted_unit_prce" do
      it "converts unit_price in cents to dollars" do
        item = Item.new(name: "Ball", description: "round", unit_price: 75106)

        formatted_price = item.formatted_unit_price

        expect(formatted_price).to eq("$751.06")
      end
    end
  end

  describe "#disabled?" do
    it "checks to see if the status of an item is disabled" do
      item = Item.new(name: "Ball", description: "round", unit_price: 75106, status: 0)
      item_2 = Item.new(name: "Ball", description: "round", unit_price: 75106, status: 1)

      expect(item.disabled?).to eq(true)
      expect(item_2.disabled?).to eq(false)
    end
  end

  describe "#enabled?" do
    it "checks to see if the status of an item is enabled" do
      item = Item.new(name: "Ball", description: "round", unit_price: 75106, status: 0)
      item_2 = Item.new(name: "Ball", description: "round", unit_price: 75106, status: 1)

      expect(item.enabled?).to eq(false)
      expect(item_2.enabled?).to eq(true)
    end
  end

  describe "#top_popular_items" do
    it "returns the top 5 most popular items for a given merchant based on revenue" do
      merchant = FactoryBot.create(:merchant)

      item_1 = FactoryBot.create(:item, merchant: merchant)
      item_2 = FactoryBot.create(:item, merchant: merchant)
      item_3 = FactoryBot.create(:item, merchant: merchant)
      item_4 = FactoryBot.create(:item, merchant: merchant)
      item_5 = FactoryBot.create(:item, merchant: merchant)

      invoice1 = FactoryBot.create(:invoice)
      invoice2 = FactoryBot.create(:invoice)
      invoice3 = FactoryBot.create(:invoice)
      invoice4 = FactoryBot.create(:invoice)
      invoice5 = FactoryBot.create(:invoice)

      FactoryBot.create(:invoice_item, item: item_1, invoice: invoice1, quantity: 10, unit_price: 1000)
      FactoryBot.create(:invoice_item, item: item_2, invoice: invoice2, quantity: 11, unit_price: 1500)
      FactoryBot.create(:invoice_item, item: item_3, invoice: invoice3, quantity: 15, unit_price: 2000)
      FactoryBot.create(:invoice_item, item: item_4, invoice: invoice4, quantity: 13, unit_price: 3000)
      FactoryBot.create(:invoice_item, item: item_5, invoice: invoice5, quantity: 25, unit_price: 2200)

      FactoryBot.create(:transaction, invoice: invoice1, result: 0)
      FactoryBot.create(:transaction, invoice: invoice2, result: 0)
      FactoryBot.create(:transaction, invoice: invoice3, result: 0)
      FactoryBot.create(:transaction, invoice: invoice4, result: 0)
      FactoryBot.create(:transaction, invoice: invoice5, result: 0)

      top_items = Item.top_popular_items(merchant.id)

      expect(top_items.length).to eq(5)
      expect(top_items).to eq([item_5, item_4, item_3, item_2, item_1])
    end
  end

  describe "#most_sales_date" do
    it "returns the most recent date that had the most salse for a particular item" do
      merchant = FactoryBot.create(:merchant)

      item_1 = FactoryBot.create(:item, merchant: merchant)
      item_2 = FactoryBot.create(:item, merchant: merchant)
      item_3 = FactoryBot.create(:item, merchant: merchant)
      item_4 = FactoryBot.create(:item, merchant: merchant)
      item_5 = FactoryBot.create(:item, merchant: merchant)

      invoice1 = FactoryBot.create(:invoice)
      invoice2 = FactoryBot.create(:invoice)
      invoice3 = FactoryBot.create(:invoice)
      invoice4 = FactoryBot.create(:invoice)
      invoice5 = FactoryBot.create(:invoice)

      FactoryBot.create(:invoice_item, item: item_1, invoice: invoice1, quantity: 10, unit_price: 1000)
      FactoryBot.create(:invoice_item, item: item_2, invoice: invoice2, quantity: 11, unit_price: 1500)
      FactoryBot.create(:invoice_item, item: item_3, invoice: invoice3, quantity: 15, unit_price: 2000)
      FactoryBot.create(:invoice_item, item: item_4, invoice: invoice4, quantity: 13, unit_price: 3000)
      FactoryBot.create(:invoice_item, item: item_5, invoice: invoice5, quantity: 25, unit_price: 2200)

      FactoryBot.create(:transaction, invoice: invoice1, result: 0)
      FactoryBot.create(:transaction, invoice: invoice2, result: 0)
      FactoryBot.create(:transaction, invoice: invoice3, result: 0)
      FactoryBot.create(:transaction, invoice: invoice4, result: 0)
      FactoryBot.create(:transaction, invoice: invoice5, result: 0)

      expected_result = item_1.most_sales_date
      expected_date = Date.today

      expect(expected_result).to eq(invoice1.created_at)
      expect(expected_result.to_date).to eq(expected_date)
    end
  end
end