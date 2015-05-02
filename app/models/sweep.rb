# A sweep represents a batch of Snapshots that were triggered simultaneously,
# such as after a deploy.
class Sweep < ActiveRecord::Base
  belongs_to            :project
  has_many              :snapshots
  attr_accessor         :delay_seconds
  validates             :title, presence: true
  validates             :email, format: { with: /\A.+@.+\Z/ },
                                allow_nil:   true,
                                allow_blank: true
  after_create          :take_snapshots,
                        :refresh_project_last_sweep
  before_create         :set_start_time_from_delay_seconds
  after_destroy         :refresh_project_last_sweep

  default_scope { order('created_at DESC') }

  def delay_seconds_remaining
    return nil unless start_time
    return nil if start_time < Time.now
    (start_time - Time.now).round
  end

  def pending_snapshots
    snapshots.select(&:pending?)
  end

  def accepted_snapshots
    snapshots.select(&:accepted?)
  end

  def rejected_snapshots
    snapshots.select(&:rejected?)
  end

  def under_review_snapshots
    snapshots.select(&:under_review?)
  end

  # Updates the snapshot counters and sends out an email if the sweep reaches a
  # "done" state. This method is using a pessimistic locking approach to avoid
  # race conditions that can cause duplicate emails to be sent and/or the
  # progress counters to be stale.
  #
  # @see
  #   http://api.rubyonrails.org/classes/ActiveRecord/Locking/Pessimistic.html
  #   for more info on pessimistic locking.
  #
  # @return [Sweep] returns itself (useful for method chaining)
  def refresh!
    with_lock do
      update_counters!
      send_email_if_needed!
      save!
    end
    self # for chaining
  end

  private

  def update_counters!
    self.count_pending      = pending_snapshots.count
    self.count_accepted     = accepted_snapshots.count
    self.count_rejected     = rejected_snapshots.count
    self.count_under_review = under_review_snapshots.count
  end

  def send_email_if_needed!
    return if email.blank?
    return if snapshots.count == 0
    return if count_pending > 0
    return if emailed_at
    SweepMailer.ready_for_review(self).deliver_now
    self.emailed_at = Time.now
  end

  def take_snapshots
    if start_time
      SweepWorker.perform_at(start_time, id)
    else
      SweepWorker.new.perform_with_sweep(self)
    end
  end

  def refresh_project_last_sweep
    project.refresh_last_sweep!
  end

  def set_start_time_from_delay_seconds
    return unless delay_seconds.to_i > 0
    self.start_time = Time.now + delay_seconds.to_i.seconds
  end
end
