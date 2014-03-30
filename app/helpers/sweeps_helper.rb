# Helper methods related to sweeps.
module SweepsHelper
  PROGRESS_BAR_STYLE_MAPPINGS = {
    'under_review' => 'progress-bar-warning',
    'accepted'     => 'progress-bar-success',
    'rejected'     => 'progress-bar-danger',
    'pending'      => 'sweep-progress-bar-pending',
  }

  # @param  [Sweep]  sweep
  # @return [String] a short textual representation of the status of a sweep
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

  # @param  [Sweep]  sweep
  # @return [String] a stacked <div class="progress"/> Bootstrap element.
  # @see http://getbootstrap.com/components/#progress
  def sweep_progress_bar(sweep)
    total_count = PROGRESS_BAR_STYLE_MAPPINGS.keys.reduce(0) do |sum, state|
      sum + sweep.send("count_#{state}")
    end

    classes = %w(progress)
    classes += %w(progress-striped active) if sweep.count_pending > 0
    html_attrs = {
      class: classes,
      title: sweep_status(sweep),
      data: {
        auto_refresh_type: 'sweep',
        auto_refresh_id:   sweep.id,
      },
    }
    content_tag(:div, html_attrs) do
      PROGRESS_BAR_STYLE_MAPPINGS.map do |state, bootstrap_class|
        percent = number_to_percentage(
                    sweep.send("count_#{state}") / total_count.to_f * 100)
        content_tag(:div, nil, class: "progress-bar #{bootstrap_class}",
                               style: "width: #{percent}")
      end.join.html_safe
    end
  end
end
