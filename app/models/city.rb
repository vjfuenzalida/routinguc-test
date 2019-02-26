# frozen_string_literal: true

class City < ApplicationRecord
  has_many :route_cities
  has_many :routes, through: :route_cities
  has_many :driver_cities
  has_many :drivers, through: :driver_cities

  def self.from_rm
    where(region: 'Región Metropolitana de Santiago')
  end
end
