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

  def start_new_sweep_button(project)
    link_to 'Start new sweep', new_project_sweep_path(project), class: 'btn btn-info'
  end
end
