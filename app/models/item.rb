class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices
  has_many :bulk_discounts, through: :merchant

  enum status: { disabled: 0, enabled: 1 }

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true, numericality: true
  
  # write method to convert string to integer for unit_price
  def formatted_unit_price
    unit_price_in_cents = self.unit_price
    dollars = unit_price_in_cents / 100
    cents = unit_price_in_cents % 100
    sprintf("$%d.%02d", dollars, cents)
  end

  def disabled?
    status == "disabled"
  end

  def enabled?
    status == "enabled"
  end

  def self.top_popular_items(merchant_id)
    joins(invoice_items: { invoice: :transactions })
      .where('items.merchant_id = ?', merchant_id)
      .where(transactions: { result: 0 })
      .select('items.*, SUM(invoice_items.quantity * invoice_items.unit_price) AS total_revenue')
      .group(:id)
      .order('total_revenue DESC')
      .limit(5)
  end

  def most_sales_date
    most_sales_date = invoices.joins(:transactions)
                             .where(transactions: { result: 0 })
                             .group(:id)
                             .order('SUM(invoice_items.quantity) DESC, invoices.created_at DESC')
                             .first&.created_at
  end
end