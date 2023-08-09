class Merchant < ApplicationRecord
  has_many :items
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices
  has_many :bulk_discounts, :dependent => :destroy

  enum status: { "enable": 0, "disable": 1 }, _default: :disable

  validates :name, presence: true

  # Instance Methods
  def top_5_customers
    transactions.joins(invoice: :customer)
      .where('transactions.result = ?', 0)
      .select("CONCAT(customers.first_name,' ', customers.last_name) AS full_name, COUNT(transactions.id) AS transaction_count")
      .group('full_name')
      .order('transaction_count DESC')
      .limit(5)
      # .to_a
  end

  def ready_to_ship
    invoice_items.joins(:item)
      .where(status: "pending")
      .select("items.*, invoice_items.*")
      .distinct
      .order('invoice_items.created_at')
  end

  def best_day
    invoices.joins(:transactions, :invoice_items)
      .where(transactions: { result: 0 })
      .select("invoices.created_at, sum(invoice_items.unit_price * invoice_items.quantity) as total_revenue")
      .group(:id)
      .order(total_revenue: :desc)
      .first.created_at
  end

  # Class methods
  def self.enabled_merchants
    where(status: 0)
  end

  def self.disabled_merchants
    where(status: 1)
  end

  def self.top_5_merchants_by_revenue
    joins(invoices: :transactions)
      .where(transactions: { result: 0 })
      .select("merchants.*, sum(invoice_items.unit_price * invoice_items.quantity) as total_revenue")
      .group(:id)
      .order(total_revenue: :desc)
      .limit(5)
  end
end    