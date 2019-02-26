class Driver < ApplicationRecord
  has_one :vehicle, required: false
  has_many :driver_cities
  has_many :cities, through: :driver_cities
end
