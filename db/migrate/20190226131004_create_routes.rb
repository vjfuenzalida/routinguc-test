class CreateRoutes < ActiveRecord::Migration[5.2]
  def change
    create_table :routes do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :load_type
      t.float :load_sum
      # t.references :cities, foreign_key: true
      t.integer :stops_amount
      # t.references :vehicle, foreign_key: true
      # t.references :driver, foreign_key: true

      t.timestamps
    end
  end
end
