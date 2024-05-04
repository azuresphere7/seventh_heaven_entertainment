class AddAmountOfTicketsToEvent < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :amount_of_tickets, :integer
  end
end
