# frozen_string_literal: true

class Route < ApplicationRecord
  belongs_to :vehicle, required: false
  belongs_to :driver, required: false
  has_many :route_cities
  has_many :cities, through: :route_cities

  def feasible_drivers(drivers)
    drivers.select { |driver| driver.accepts_route?(self) }
  end

  def feasible_vehicles(drivers, vehicles)
    # vehicles with drivers that cover the route area
    owned_vehicles = feasible_drivers(drivers).map(&:vehicle).compact
    # vehicles without driver
    empty_vehicles = vehicles.select { |v| v.id.nil? }

    available_vehicles = owned_vehicles + empty_vehicles

    available_vehicles.select { |v| v.allows_route?(self) }
  end

  def overlaps?(other_route)
    starts_at <= other_route.ends_at && other_route.starts_at <= ends_at
  end
end
