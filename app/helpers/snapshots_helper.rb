module SnapshotsHelper
  def snapshot_status(snapshot)
    if snapshot.pending?
      'Pending'
    elsif snapshot.accepted?
      'Accepted'
    elsif snapshot.rejected?
      'Rejected'
    else
      'Under review'
    end
  end
end
