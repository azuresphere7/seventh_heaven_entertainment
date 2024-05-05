class CreateCustomerInfos < ActiveRecord::Migration[7.1]
  def change
    create_table :customer_infos do |t|
      t.references :order, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :gender
      t.integer :age

      t.timestamps
    end
  end
end
