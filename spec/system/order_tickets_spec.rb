require "rails_helper"

RSpec.describe "Order tickets for an event", :js do
  before do
    @event = create(:event)
  end

  it "allows a user to create an event from the home page" do
    visit root_path
    fill_in "Number of Tickets (max 6):", with: 2
    click_link_or_button "Order"

    expect(page).to have_content("Order was successfully created.")
  end
end
