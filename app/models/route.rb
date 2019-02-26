class Route < ApplicationRecord
  belongs_to :vehicle, required: false
  belongs_to :driver, required: false
  has_many :route_cities
  has_many :cities, through: :route_cities
end
