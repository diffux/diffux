# Helper methods related to sweeps.
module SweepsHelper
  def sweep_status(sweep)
    if sweep.count_pending > 0
      pluralize(sweep.count_pending, 'pending snapshot')
    elsif sweep.count_under_review > 0
      "#{pluralize(sweep.count_under_review, 'snapshot')} under review"
    elsif sweep.count_rejected > 0

      "#{sweep.count_accepted} accepted, #{sweep.count_rejected} rejected"
    elsif sweep.count_accepted > 0
      'All accepted'
    else
      'Unknown'
    end
  end
end
