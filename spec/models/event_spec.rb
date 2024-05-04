require "rails_helper"
RSpec.describe Event do
  describe "#title" do
    it "is required" do
      event = build(:event, title: nil)
      event.valid?
      expect(event.errors.messages[:title]).to include("can't be blank")
    end
  end

  describe "#price" do
    it "is required" do
      event = build(:event, price: nil)
      event.valid?
      expect(event.errors.messages[:price]).to include("can't be blank")
    end
  end

  describe "#location" do
    it "is required" do
      event = build(:event, location: nil)
      event.valid?
      expect(event.errors.messages[:location]).to include("can't be blank")
    end
  end

  describe "#starts_on" do
    it "is required" do
      event = build(:event, starts_on: nil)
      event.valid?
      expect(event.errors.messages[:starts_on]).to include("can't be blank")
    end

    it "is in the future" do
      event = build(:event, starts_on: Date.yesterday)
      event.valid?
      expect(event.errors.messages[:starts_on]).to include("must be in the future")
    end
  end

  describe "#ends_on" do
    it "is required" do
      event = build(:event, ends_on: nil)
      event.valid?
      expect(event.errors.messages[:ends_on]).to include("can't be blank")
    end

    it "is after the starts_on date" do
      event = build(:event, starts_on: Time.zone.today, ends_on: Date.yesterday)
      event.valid?
      expect(event.errors.messages[:ends_on]).to include("must be after the starts_on date")
    end
  end

  describe "#amount_of_tickets" do
    it "is required" do
      event = build(:event, amount_of_tickets: nil)
      event.valid?
      expect(event.errors.messages[:amount_of_tickets]).to include("can't be blank")
    end

    it "is greater than 0" do
      event = build(:event, amount_of_tickets: 0)
      event.valid?
      expect(event.errors.messages[:amount_of_tickets]).to include("must be greater than 0")
    end
  end

  describe "#event_queue" do
    it "is initialized after initialization" do
      event = described_class.new
      expect(event.event_queue).to be_present
    end

    it "is required" do
      event = build(:event)
      event.event_queue = nil
      event.valid?
      expect(event.errors.messages[:event_queue]).to include("can't be blank")
    end

    it "is saved together with the event" do
      event = create(:event)
      expect(event.event_queue).to be_persisted
    end
  end
end
