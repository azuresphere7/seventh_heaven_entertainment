# Seed data for events organized by 7th Heaven Entertainment Show

# Event 1
Event.create!(
  title: "Magic of Music: A Night with The Enchanting Orchestra",
  price: "25.0",
  starts_on: 2.days.from_now,
  ends_on: 2.days.from_now + 3.hours,
  location: "7th Heaven Arena",
  capacity: 150,
  description: "Experience the magical blend of symphony and rhythm as The Enchanting Orchestra takes you on a journey through the wonders of music. Don't miss this enchanting night filled with melodious tunes and captivating performances."
)

# Event 2
Event.create!(
  title: "Circus Spectacular: A Night Under the Big Top",
  price: "30.0",
  starts_on: 4.days.from_now,
  ends_on: 4.days.from_now + 4.hours,
  location: "7th Heaven Circus Grounds",
  capacity: 200,
  description: "Step right up and be amazed by the extraordinary feats of acrobatics, daring stunts, and comedic antics at our Circus Spectacular! Join us for a night of wonder and excitement as we bring the magic of the circus to life under the big top."
)

# Event 3
Event.create!(
  title: "Masquerade Ball: A Night of Mystery and Intrigue",
  price: "35.0",
  starts_on: 6.days.from_now,
  ends_on: 6.days.from_now + 5.hours,
  location: "7th Heaven Grand Ballroom",
  capacity: 250,
  description: "Indulge in an evening of elegance and mystery at our Masquerade Ball. Don your most glamorous attire and don a mask as you dance the night away amidst enchanting music and hidden identities. Prepare to be swept off your feet by the allure of the unknown."
)

# Event 4
Event.create!(
  title: "Movie Night Under the Stars: A Tribute to Classic Cinema",
  price: "20.0",
  starts_on: 8.days.from_now,
  ends_on: 8.days.from_now + 3.hours,
  location: "7th Heaven Outdoor Amphitheater",
  capacity: 100,
  description: "Join us for a nostalgic journey through the golden age of cinema at our Movie Night Under the Stars. Sit back, relax, and enjoy timeless classics under the open sky as we pay tribute to the cinematic legends that have captured our hearts for generations."
)
