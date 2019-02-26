class RouteCity < ApplicationRecord
  belongs_to :route
  belongs_to :city
end
