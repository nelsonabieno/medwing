class CreateReadings < ActiveRecord::Migration
  def change
    create_table :readings do |t|
      t.references :thermostat, index: true
      t.float :temperature
      t.float :humidity
      t.integer :battery_charge

      t.timestamps
    end
  end
end
