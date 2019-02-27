class AddMaxStopsToDrivers < ActiveRecord::Migration[5.2]
  def change
    add_column :drivers, :max_stops, :integer
  end
end
