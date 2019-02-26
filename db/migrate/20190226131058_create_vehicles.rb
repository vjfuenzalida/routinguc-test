class CreateVehicles < ActiveRecord::Migration[5.2]
  def change
    create_table :vehicles do |t|
      t.float :capacity
      t.string :load_type
      # t.references :driver, foreign_key: true

      t.timestamps
    end
  end
end
