# A sweep represents a batch of Snapshots that were triggered simultaneously,
# such as after a deploy.
class Sweep < ActiveRecord::Base
  belongs_to            :project
  has_many              :snapshots
  attr_accessor         :delay_seconds
  validates_presence_of :title
  validates_format_of   :email, with: /\A.+@.+\Z/,
                                allow_nil:   true,
                                allow_blank: true
  after_create          :take_snapshots
  before_create         :set_start_time_from_delay_seconds

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

  def refresh!
    update_counters!
    send_email_if_needed!
  end

  private

  def update_counters!
    self.count_pending      = pending_snapshots.count
    self.count_accepted     = accepted_snapshots.count
    self.count_rejected     = rejected_snapshots.count
    self.count_under_review = under_review_snapshots.count
    save!
  end

  def send_email_if_needed!
    return unless email
    update_counters! # to prevent stale data
    return if snapshots.count == 0
    return if count_pending > 0
    return if emailed_at
    SweepMailer.ready_for_review(self).deliver
    self.emailed_at = Time.now
    save!
  end

  def take_snapshots
    if start_time
      SweepWorker.perform_at(start_time, id)
    else
      SweepWorker.new.perform_with_sweep(self)
    end
  end

  def set_start_time_from_delay_seconds
    return unless delay_seconds.to_i > 0
    self.start_time = Time.now + delay_seconds.to_i.seconds
  end
end
