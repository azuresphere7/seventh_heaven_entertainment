class CreateEventQueues < ActiveRecord::Migration[7.1]
  def change
    create_table :event_queues do |t|
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
