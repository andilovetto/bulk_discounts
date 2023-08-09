
InvoiceItem.destroy_all
Item.destroy_all
Transaction.destroy_all
Invoice.destroy_all
Customer.destroy_all
Merchant.destroy_all
BulkDiscount.destroy_all

Rake::Task["csv_load:all"].invoke


