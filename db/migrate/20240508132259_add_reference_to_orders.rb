class AddReferenceToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :reference, :string
    add_index :orders, :reference, unique: true
  end
end
