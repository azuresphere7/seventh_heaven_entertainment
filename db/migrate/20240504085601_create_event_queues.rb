class CreateEventQueues < ActiveRecord::Migration[7.1]
  def change
    create_table :ticket_sales do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :number_of_sold_tickets, default: 0
      t.integer :number_of_reserved_tickets, default: 0
      t.integer :capacity, default: 0

      t.timestamps
    end
  end
end
