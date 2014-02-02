class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.timestamps
    end

    create_table :viewports do |t|
      t.references :project
      t.integer :width, limit: 2 # smallint
      t.timestamps
    end

    change_table :urls do |t|
      t.references :project
      t.remove :viewport_width
    end

    change_table :snapshots do |t|
      t.references :viewport
    end
  end
end
