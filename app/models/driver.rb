# frozen_string_literal: true

class Driver < ApplicationRecord
  has_one :vehicle, required: false
  has_many :driver_cities
  has_many :cities, through: :driver_cities

  scope :with_vehicle, -> { where.not(vehicle_id: nil) }
  scope :without_vehicle, -> { where(vehicle_id: nil) }

  def in_area?(city_array)
    route_cities = city_array.pluck(:id)
    driver_cities = cities.pluck(:id)
    (route_cities - driver_cities).empty?
  end

  def accepts_stops?(stops_amount)
    max_stops >= stops_amount
  end

  def allows_route?(route)
    in_area?(route.cities) && accepts_stops?(route.stops_amount)
  end

end
