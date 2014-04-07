class AddLastSweepIdToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :last_sweep, references: :sweeps
  end
end
