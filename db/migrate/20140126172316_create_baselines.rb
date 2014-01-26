class CreateBaselines < ActiveRecord::Migration
  def change
    create_table :baselines do |t|
      t.references :url
      t.references :snapshot
      t.timestamps
    end
  end
end
