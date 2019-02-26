class CreateDriverCities < ActiveRecord::Migration[5.2]
  def change
    create_table :driver_cities do |t|
      t.references :driver, foreign_key: true
      t.references :city, foreign_key: true

      t.timestamps
    end
  end
end
