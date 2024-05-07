class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :title
      t.decimal :price, precision: 10, scale: 2
      t.datetime :starts_on
      t.datetime :ends_on
      t.string :location

      t.timestamps
    end
  end
end
