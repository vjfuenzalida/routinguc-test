class Vehicle < ApplicationRecord
  belongs_to :driver, required: false
end
