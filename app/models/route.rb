class Route < ApplicationRecord
  belongs_to :vehicle
  belongs_to :driver
  has_many :route_cities
  has_many :cities, through: :route_cities
end
