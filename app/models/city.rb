class City < ApplicationRecord
  has_many :route_cities
  has_many :routes, through: :route_cities
end
