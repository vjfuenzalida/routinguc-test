class CreateRouteCities < ActiveRecord::Migration[5.2]
  def change
    create_table :route_cities do |t|
      t.references :route, foreign_key: true
      t.references :city, foreign_key: true

      t.timestamps
    end
  end
end
