class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :title
      t.decimal :price
      t.datetime :starts_on
      t.datetime :ends_on

      t.timestamps
    end
  end
end
