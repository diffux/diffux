# Utility class that can be used to clean up databases that are in bad states.
class DBCleanup
  # Finds orphaned entities and deletes them. By default, a dryrun will be made.
  # To actually delete things, you need to pass in `dryrun: false`.
  def self.destroy_all_orphans!(dryrun: true)
    destroy_orphans!(dryrun: dryrun, klass: Url,      parent: :project)
    destroy_orphans!(dryrun: dryrun, klass: Sweep,    parent: :project)
    destroy_orphans!(dryrun: dryrun, klass: Viewport, parent: :project)
    destroy_orphans!(dryrun: dryrun, klass: Snapshot, parent: :url)
    destroy_orphans!(dryrun: dryrun, klass: SnapshotDiff,
                                     parent: :after_snapshot)
    destroy_orphans!(dryrun: dryrun, klass: SnapshotDiffCluster,
                                     parent: :snapshot_diff)
  end

  def self.destroy_orphans!(klass: raise, parent: raise, dryrun: true)
    klass.all.includes(parent).each do |obj|
      if obj.send(parent).blank?
        if dryrun
          puts "(dryrun) would have deleted #{klass} with id #{obj.id}"
        else
          puts "Deleting #{klass} with id #{obj.id}"
          obj.destroy
        end
      end
    end
  end
end
