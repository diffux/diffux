class AddUrlsCounterCacheToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :urls_count, :integer, default: 0

    Project.reset_column_information
    Project.find_each do |p|
      Project.update_counters p.id, urls_count: p.urls.length
    end
  end

  def down
    remove_column :projects, :urls_count
  end
end
