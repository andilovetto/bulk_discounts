require "rails_helper"

RSpec.describe Merchant, type: :model do
  
  describe "relationships" do
    it { should have_many(:items) }
    it { should have_many(:invoice_items).through(:items) }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should have_many(:customers).through(:invoices) }
    it { should have_many(:transactions).through(:invoices) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should define_enum_for(:status) }
  end

  describe "#instance_methods" do
    before(:each) do
      @merchant_1 = Merchant.create!(name: "Schroeder-Jerde", status: nil)
      @items = create_list(:item, 20, merchant: @merchant_1)
  
      # Create invoices with and associate with items
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

    describe "#top_5_customers" do
      it "can list the merchant's top 5 customers" do
        expect(@merchant_1.top_5_customers.length).to eq(5)
      end
    end 

    describe "#ready_to_ship" do
      it "can list items that are ready to ship and order items from oldest to newest" do
        ready_to_ship_invoice_items = @invoices.map do |invoice|
          create(:invoice_item, item: @items.sample, invoice: invoice, status: 1)
        end
        
        item_names = @merchant_1.ready_to_ship.each do |invoice_item|
          invoice_item.name
        end

        expect(@merchant_1.ready_to_ship).not_to be_empty
        expect(@merchant_1.ready_to_ship).to include(*item_names)
        
        # User Story 5
        created_dates = @merchant_1.ready_to_ship.map do |item|
          item.created_at
        end
        
        expect(created_dates).to eq(created_dates.sort)
      end
    end

    describe "#best_day" do

      let!(:little_kin_shop) { create(:merchant, name: "jam threads") }
      let!(:jimmy) { create(:customer) }
      let!(:item_1) { create(:item, merchant_id: little_kin_shop.id) }
      let!(:invoice_1) { create(:invoice, customer_id: jimmy.id, created_at: '2022-01-15 23:48:56 UTC') }
      let!(:invoice_11) { create(:invoice, customer_id: jimmy.id, created_at: '2023-07-29 23:48:56 UTC') }
      let!(:transaction_1) { create(:transaction, result: 0, invoice_id: invoice_1.id) }
      let!(:invoice_item_1) { create(:invoice_item, invoice_id: invoice_1.id, item_id: item_1.id, unit_price: 1000, quantity: 1000) }
      let!(:invoice_item_11) { create(:invoice_item, invoice_id: invoice_11.id, item_id: item_1.id, unit_price: 1000, quantity: 500) }

      it "displays the best day for a merchant" do
        expect(little_kin_shop.best_day).to eq(invoice_1.created_at)
      end
    end
  end
  
  
  describe "class methods" do
    let!(:little_kin_shop) { create(:merchant, status: 0) }
    let!(:bowlegged_woman) { create(:merchant, status: 0) }
    let!(:halloween_face) { create(:merchant, status: 0) }
    let!(:tall_boy) { create(:merchant) }
    let!(:arleen) { create(:merchant) }
    let!(:bust_it_big) { create(:merchant) }

    describe ".enabled_merchants" do
      it "returns an array of enabled merchants" do
        expect(Merchant.enabled_merchants).to eq([little_kin_shop, bowlegged_woman, halloween_face])
      end
    end
    
    describe ".disabled_merchants" do
      it "returns an array of disabled merchants" do
        expect(Merchant.disabled_merchants).to eq([tall_boy, arleen, bust_it_big])
      end
    end

    describe ".top_5_merchants_by_revenue" do
      let!(:little_kin_shop) { create(:merchant, name: "jam threads") }
      let!(:jimmy) { create(:customer) }
      let!(:item_1) { create(:item, merchant_id: little_kin_shop.id) }
      let!(:invoice_1) { create(:invoice, customer_id: jimmy.id) }
      let!(:transaction_1) { create(:transaction, result: 0, invoice_id: invoice_1.id) }
      let!(:invoice_item_1) { create(:invoice_item, invoice_id: invoice_1.id, item_id: item_1.id, unit_price: 1000, quantity: 1000) }
  
      let!(:halloween_face) { create(:merchant,name: "costumes") }
      let!(:schools) { create(:customer) }
      let!(:item_2) { create(:item, merchant_id: halloween_face.id) }
      let!(:invoice_2) { create(:invoice, customer_id: schools.id) }
      let!(:transaction_2) { create(:transaction, result: 0, invoice_id: invoice_2.id) }
      let!(:invoice_item_2) { create(:invoice_item, invoice_id: invoice_2.id, item_id: item_2.id, unit_price: 1000, quantity: 900) }
      
      let!(:tall_boy) { create(:merchant, name: "craft delights") }
      let!(:john_bell) { create(:customer) }
      let!(:item_3) { create(:item, merchant_id: tall_boy.id) }
      let!(:invoice_3) { create(:invoice, customer_id: john_bell.id) }
      let!(:transaction_3) { create(:transaction, result: 0, invoice_id: invoice_3.id) }
      let!(:invoice_item_3) { create(:invoice_item, invoice_id: invoice_3.id, item_id: item_3.id, unit_price: 1000, quantity: 800) }
  
      let!(:diner) { create(:merchant, name: "unique gifts") }
      let!(:jb) { create(:customer) }
      let!(:item_4) { create(:item, merchant_id: diner.id) }
      let!(:invoice_4) { create(:invoice, customer_id: jb.id) }
      let!(:transaction_4) { create(:transaction, result: 0, invoice_id: invoice_4.id) }
      let!(:invoice_item_4) { create(:invoice_item, invoice_id: invoice_4.id, item_id: item_4.id, unit_price: 1000, quantity: 700) }
      
      let!(:bowlegged_woman) { create(:merchant, name: "lingerie shop") }
      let!(:sunny) { create(:customer) }
      let!(:item_5) { create(:item, merchant_id: bowlegged_woman.id) }
      let!(:invoice_5) { create(:invoice, customer_id: sunny.id) }
      let!(:transaction_5) { create(:transaction, result: 0, invoice_id: invoice_5.id) }
      let!(:invoice_item_5) { create(:invoice_item, invoice_id: invoice_5.id, item_id: item_5.id, unit_price: 1000, quantity: 600) }
  
      let!(:arleen) { create(:merchant, name: "great guitars") }
      let!(:duane) { create(:customer) }
      let!(:item_6) { create(:item, merchant_id: arleen.id) }
      let!(:invoice_6) { create(:invoice, customer_id: duane.id) }
      let!(:transaction_6) { create(:transaction, result: 0, invoice_id: invoice_6.id) }
      let!(:invoice_item_6) { create(:invoice_item, invoice_id: invoice_6.id, item_id: item_6.id, unit_price: 1000, quantity: 500) }
      
      let!(:bust_it_big) { create(:merchant, name: "swimwear") }
      let!(:jojo) { create(:customer) }
      let!(:item_7) { create(:item, merchant_id: bust_it_big.id) }
      let!(:invoice_7) { create(:invoice, customer_id: jojo.id) }
      let!(:transaction_7) { create(:transaction, result: 0, invoice_id: invoice_7.id) }
      let!(:invoice_item_7) { create(:invoice_item, invoice_id: invoice_7.id, item_id: item_7.id, unit_price: 1000, quantity: 400) }

      it "returns an array of top 5 merchants by revenue" do
        expect(Merchant.top_5_merchants_by_revenue).to eq([little_kin_shop, halloween_face, tall_boy, diner, bowlegged_woman])
      end
    end
  end
end