require "rails_helper"

RSpec.describe "Creating an event", :js do
  before { create(:event) }

  it "allows a user to create an event from the home page" do
    visit admin_events_path

    click_link_or_button "Show this event"
    click_link_or_button "Edit this event"

    fill_in "Title", with: ""

    click_link_or_button "Save"
    expect(page).to have_content("Title can't be blank")

    fill_in "Title", with: "A new title"
    click_link_or_button "Save"

    expect(page).to have_content("Event was successfully updated.")
    expect(page).to have_content("A new title")
    expect(page).to have_content("MyText")
  end
end
