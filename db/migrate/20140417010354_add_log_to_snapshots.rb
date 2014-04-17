class AddLogToSnapshots < ActiveRecord::Migration
  def change
    change_table :snapshots do |t|
      t.text :log
    end
  end
end
