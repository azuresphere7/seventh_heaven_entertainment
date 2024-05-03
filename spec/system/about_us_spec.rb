require "rails_helper"

RSpec.describe "About us" do
  it "displays the about us page" do
    visit pages_about_us_path

    expect(page).to have_css("h1", text: "Pages#about_us")
  end
end
