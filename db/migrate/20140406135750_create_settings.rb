class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :key
      t.string :value, limit: 1000

      t.timestamps
    end
  end
end
