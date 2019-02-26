class DriverCity < ApplicationRecord
  belongs_to :driver
  belongs_to :city
end
