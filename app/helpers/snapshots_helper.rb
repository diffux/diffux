# Helper methods related to Snapshots.
module SnapshotsHelper
  def glyphicon_for(snapshot)
    if snapshot.pending?
      nil
    elsif snapshot.accepted?
      'glyphicon-ok-sign'
    elsif snapshot.rejected?
      'glyphicon-remove-sign'
    else
      'glyphicon-question-sign'
    end
  end

  def start_new_sweep_button(project)
    link_to t(:new_sweep), new_project_sweep_path(project),
            class: 'btn btn-primary'
  end
end
