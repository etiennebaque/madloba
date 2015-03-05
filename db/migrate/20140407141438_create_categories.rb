class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.string :marker_color
      t.text :description

      t.timestamps
    end
  end
end
