class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :robot_id
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
