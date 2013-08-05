class AddUrlIdToSnapshots < ActiveRecord::Migration
  def change
    change_table :snapshots do |t|
      t.references :url
    end
  end
end
