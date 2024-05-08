require "rails_helper"

RSpec.describe "Creating an event", :js do
  it "allows a user to create an event from the home page" do
    visit admin_events_path

    click_link_or_button "New event"
    fill_in "Title", with: "My Event"
    fill_in "Price", with: "10.00"
    fill_in "Location", with: "123 Main St, City"
    fill_in "Starts on", with: Time.zone.parse("2025-01-01 17:00")
    fill_in "Ends on", with: Time.zone.parse("2025-01-01 01:00")
    fill_in "Capacity", with: 100
    fill_in_rich_text_area "Description", with: "This is my <em>event</em> description"

    click_link_or_button "Save"
    expect(page).to have_content("Ends on must be after the starts_on date")

    fill_in "Ends on", with: Time.zone.parse("2025-01-02 01:00")
    click_link_or_button "Save"

    expect(page).to have_content("Event was successfully created.")
    expect(page).to have_content("My Event")
    expect(page).to have_content("This is my event description")
    expect(page).to have_content("123 Main St, City")
    expect(page).to have_content("01 Jan 17:00 - 02 Jan 01:00")
  end
end
