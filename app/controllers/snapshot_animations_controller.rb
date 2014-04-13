# Controller for generating animations of snapshots
class SnapshotAnimationsController < ApplicationController
  def show
    @animation_path = nil
    accepted = Snapshot.unscoped.accepted.includes(:snapshot_diff)
                       .where(url: params[:id], viewport: params[:viewport])
                       .order('created_at ASC')

    different = accepted.select do |snapshot|
      snapshot.snapshot_diff && snapshot.snapshot_diff.diff_in_percent > 0
    end

    snapshots = [accepted.first] + different

    return unless snapshots.size > 1

    frames = snapshots.map do |snapshot|
      snapshot.image.path
    end

    cmd = []
    cmd << '-delay 50'  # .5s frame duration (in n/100ths of a second)
    cmd += frames[0...-1]
    cmd << '-delay 250' # 2.5s pause after last frame to signify loop
    cmd << frames[-1]
    cmd << '-loop 0'    # infinite loop

    filename_hash       = Digest::MD5.hexdigest(cmd.join(' '))
    output_filename     = "#{filename_hash}.gif"
    @animation_path     = "/system/snapshot_animations/#{output_filename}"
    full_animation_path = "#{Rails.root}/public#{@animation_path}"

    unless File.exists? full_animation_path
      FileUtils.mkdir_p File.dirname(full_animation_path)
      `convert #{cmd.join(' ')} #{full_animation_path}`
    end
  end
end
