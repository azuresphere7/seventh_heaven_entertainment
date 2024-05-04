json.extract! event, :id, :title, :price, :starts_on, :ends_on, :created_at, :updated_at
json.url event_url(event, format: :json)
