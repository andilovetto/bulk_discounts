class InvoiceItem < ApplicationRecord
  validates_presence_of :invoice_id,
  :item_id,
  :quantity,
  :unit_price,
  :status

  belongs_to :invoice
  belongs_to :item
  has_many :bulk_discounts, through: :item

  validates :quantity, presence: true, numericality: true
  validates :unit_price, presence: true, numericality: true
  validates :status, presence: true

  enum status: {
                'packaged': 0,
                'pending': 1,
                'shipped': 2
                }


def self.incomplete_invoices
  invoice_ids = InvoiceItem.where("status = 0 OR status = 1").pluck(:invoice_id)
  Invoice.order(created_at: :asc).find(invoice_ids)
  end
         
  def format_price
    unit_price_in_cents = self.unit_price
    dollars = unit_price_in_cents / 100
    cents = unit_price_in_cents % 100
    sprintf("$%d.%02d", dollars, cents)
  end  

  # def discount_available
  #   bulk_discounts.where("bulk_discounts.threshold <= ?", quantity).order(percentage: :desc).first
  # end
end
  