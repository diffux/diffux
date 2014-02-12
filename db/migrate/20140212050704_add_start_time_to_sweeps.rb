class AddStartTimeToSweeps < ActiveRecord::Migration
  def change
    add_column :sweeps, :start_time, :timestamp
  end
end
