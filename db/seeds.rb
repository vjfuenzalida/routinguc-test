# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

####### CITIES #######

chilean_communes = JSON.parse(File.read(Rails.root.join('db', 'chile.json')))
chilean_communes.each do |commune|
  City.create(name: commune['name'], region: commune['region'])
end

ROUTE_COUNT = 80

####### DRIVERS #######

DRIVER_COUNT = 50

# Generate parameters for drivers
names = Array.new(DRIVER_COUNT).map { |_t| Faker::Name.name }
emails = names.map { |name| Faker::Internet.email(name) }
phones = names.map { |_n| Faker::PhoneNumber.cell_phone }

# Create fake drivers
DRIVER_COUNT.times do |t|
  Driver.create(
    name: names[t],
    email: emails[t],
    phone: phones[t],
    vehicle: nil,
    cities: City.from_rm.sample(rand(5..10))
  )
end

####### VEHICLES #######

VEHICLE_COUNT = 40
WITHOUT_DRIVER = 10
MEAN_CAPACITY = 300
SD_CAPACITY = 150

# Generate parameters for vehicles
capacities = Array.new(VEHICLE_COUNT).map do |_t|
  Faker::Number.normal(MEAN_CAPACITY, SD_CAPACITY).round(2)
end
load_types = Array.new(VEHICLE_COUNT).map do |_t|
  %w[general refrigerated].sample
end
driver_ids = ((1..(VEHICLE_COUNT - WITHOUT_DRIVER)).to_a + [nil] * WITHOUT_DRIVER).shuffle

# Create fake vehicles (ids 0 to 39)
VEHICLE_COUNT.times do |t|
  Vehicle.create(
    capacity: capacities[t],
    load_type: load_types[t],
    driver_id: driver_ids[t]
  )
  Driver.find(driver_ids[t]).update(vehicle_id: t + 1) if driver_ids[t]
end

####### ROUTES #######

Route.create(
  starts_at: DateTime.now + 1.hour,
  ends_at: DateTime.now + 2.hour + 35.minutes,
  load_type: 'refrigerated',
  load_sum: 320,
  stops_amount: 5,
  cities: City.from_rm.sample(2)
)

Route.create(
  starts_at: DateTime.now + 1.hour + 15.minutes,
  ends_at: DateTime.now + 4.hour + 35.minutes,
  load_type: 'general',
  load_sum: 400,
  stops_amount: 8,
  cities: City.from_rm.sample(3)
)

Route.create(
  starts_at: DateTime.now + 3.hour,
  ends_at: DateTime.now + 5.hour + 35.minutes,
  load_type: 'refrigerated',
  load_sum: 220,
  stops_amount: 6,
  cities: City.from_rm.sample(1)
)
