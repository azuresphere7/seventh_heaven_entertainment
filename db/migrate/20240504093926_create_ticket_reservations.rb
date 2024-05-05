class CreateTicketReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :ticket_reservations do |t|
      t.references :ticket_sale, null: false, foreign_key: true
      t.string :reservation_number, index: {unique: true}
      t.integer :quantity
      t.string :status
      t.datetime :valid_until

      t.timestamps
    end
  end
end
