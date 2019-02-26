class AddReferencesToModels < ActiveRecord::Migration[5.2]
  def change
    add_reference :routes, :vehicle, foreign_key: true
    add_reference :routes, :driver, foreign_key: true
    add_reference :vehicles, :driver, foreign_key: true
    add_reference :drivers, :vehicle, foreign_key: true
  end
end
