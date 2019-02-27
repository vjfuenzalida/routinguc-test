# frozen_string_literal: true

class Vehicle < ApplicationRecord
  belongs_to :driver, required: false

  scope :supporting_load_of, ->(load_sum) { where('capacity >= ?', load_sum) }
  scope :of_type, ->(type) { where(load_type: type) }
  scope :with_ids, ->(id_array) { where(id: id_array) }
  scope :owned, -> { where.not(driver_id: nil) }
  scope :not_owned, -> { where(driver_id: nil) }

  def supports_load_sum?(load_sum)
    capacity >= load_sum
  end

  def supports_load_type?(type)
    load_type == type
  end

  def allows_route?(route)
    supports_load_sum?(route.load_sum) && supports_load_type?(route.load_type)
  end

  def self.elegible_for_route(route)
    of_type(route.load_type).supporting_load_of(route.load_sum)
  end
end
