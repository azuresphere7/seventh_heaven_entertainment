class AddAmountOfTicketsToEvent < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :capacity, :integer
  end
end
