class CreateQueuedOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :queued_orders do |t|
      t.references :order, null: false, foreign_key: true
      t.references :event_queue, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
