# Worker that triggers snapshots for a sweep
class SweepWorker
  include Sidekiq::Worker

  def perform(sweep_id)
    sweep = Sweep.find(sweep_id)
    return unless sweep
    perform_with_sweep sweep
  end

  def perform_with_sweep(sweep)
    sweep.project.urls.each do |url|
      sweep.project.viewports.each do |viewport|
        snapshot          = Snapshot.new
        snapshot.viewport = viewport
        snapshot.url      = url
        snapshot.sweep    = sweep
        snapshot.save!
      end
    end
  end
end
