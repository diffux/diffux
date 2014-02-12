class Sweep < ActiveRecord::Base
  belongs_to            :project
  has_many              :snapshots
  attr_accessor         :delay_seconds
  validates_presence_of :title
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

  def update_counters!
    self.count_pending      = pending_snapshots.count
    self.count_accepted     = accepted_snapshots.count
    self.count_rejected     = rejected_snapshots.count
    self.count_under_review = under_review_snapshots.count
    save!
  end

  private

  def take_snapshots
    if start_time
      SweepWorker.perform_at(start_time, id)
    else
      SweepWorker.new.perform_with_sweep(self)
    end
  end

  def set_start_time_from_delay_seconds
    return unless delay_seconds
    self.start_time = Time.now + delay_seconds.to_i.seconds
  end
end
