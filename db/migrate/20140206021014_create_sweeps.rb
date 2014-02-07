class CreateSweeps < ActiveRecord::Migration
  def change
    create_table :sweeps do |t|
      t.references :project
      t.string     :title, null: false
      t.text       :description
      t.timestamps
    end
  end
end
