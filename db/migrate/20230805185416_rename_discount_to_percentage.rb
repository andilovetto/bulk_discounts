class RenameDiscountToPercentage < ActiveRecord::Migration[7.0]
  def change
    rename_column :bulk_discounts, :discount, :percentage
  end
end
