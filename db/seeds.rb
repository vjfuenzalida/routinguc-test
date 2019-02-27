### Constants!!

DRIVER_COUNT = 50
VEHICLE_COUNT = 40
WITHOUT_DRIVER = 10
ROUTE_COUNT = 20
MIN_CAPACITY = 100
MAX_CAPACITY = 500
LOAD_TYPES = %w[general refrigerated].freeze

####### CITIES #######

chilean_communes = JSON.parse(File.read(Rails.root.join('db', 'chile.json')))
chilean_communes.each do |commune|
  City.create(name: commune['name'], region: commune['region'])
end

####### DRIVERS #######


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
    cities: City.from_rm.sample(rand(8..20)),
    max_stops: rand(4..10)
  )
end

####### VEHICLES #######

# Generate parameters for vehicles
capacities = Array.new(VEHICLE_COUNT).map do |_t|
  Faker::Number.between(MIN_CAPACITY, MAX_CAPACITY).round(0)
end
load_types = Array.new(VEHICLE_COUNT).map do |_t|
  LOAD_TYPES.sample
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

ROUTE_COUNT.times do |_t|
  today = DateTime.parse('2019-02-27 00:00:00-03:00')
  start_hour = rand(2..14)
  start_minute = rand(0..59)
  # start_minute = 0
  end_hour = rand((start_hour + 1)..(start_hour + 4))
  end_minute = rand(0..59)
  # end_minute = 59
  Route.create(
    starts_at: today + start_hour.hours + start_minute.minutes,
    ends_at: today + end_hour.hours + end_minute.minutes,
    load_type: LOAD_TYPES.sample,
    load_sum: rand(200..400),
    stops_amount: rand(1..8),
    cities: City.from_rm.sample(rand(1..3))
  )
end
