class AddEmailFieldsToSweep < ActiveRecord::Migration
  def change
    add_column :sweeps, :email,      :string
    add_column :sweeps, :emailed_at, :timestamp
  end
end
