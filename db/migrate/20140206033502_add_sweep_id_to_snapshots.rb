class AddSweepIdToSnapshots < ActiveRecord::Migration
  def change
    add_reference :snapshots, :sweep, index: true
  end
end
