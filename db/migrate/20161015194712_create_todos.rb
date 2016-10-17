class CreateTodos < ActiveRecord::Migration
  def change
    create_table :todos do |t|
      t.string :description
      t.string :condition
      t.string :alert

      t.timestamps null: false
    end
  end
end
