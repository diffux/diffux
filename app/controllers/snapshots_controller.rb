# Mostly RESTful controller for Snapshot model.
class SnapshotsController < ApplicationController
  before_filter :set_snapshot,
                only: %i[show destroy accept reject view_log take_snapshot
                         compare_snapshot]

  def show
    @review_list = @snapshot.sweep.snapshots if @snapshot.sweep
    render
  end

  def create
    url = Url.find(params.delete(:url))

    url.project.viewports.each do |viewport|
      @snapshot          = Snapshot.new
      @snapshot.viewport = viewport
      @snapshot.url      = url
      @snapshot.save!
    end

    redirect_to url,
                notice: t(:model_created,
                          model_name: Snapshot.model_name.human(count: 2),
                          count: 2)
  end

  def destroy
    @snapshot.destroy

    redirect_to @snapshot.url.project,
                notice: t(:model_destroyed,
                          model_name: @snapshot.class.model_name.human)
  end

  def reject
    @snapshot.reject!
    if request.xhr?
      render partial: 'snapshots/header_and_buttons'
    else
      redirect_to @snapshot
    end
  end

  def accept
    @snapshot.accept!
    if request.xhr?
      render partial: 'snapshots/header_and_buttons'
    else
      redirect_to @snapshot
    end
  end

  def view_log
    render
  end

  def take_snapshot
    @snapshot.image                = nil
    @snapshot.accepted_at          = nil
    @snapshot.rejected_at          = nil
    @snapshot.snapshot_diff.try(:destroy!)
    @snapshot.snapshot_diff        = nil
    @snapshot.save!

    @snapshot.take_snapshot

    redirect_to @snapshot, notice: t(:snapshot_retaken)
  end

  def compare_snapshot
    @snapshot.accepted_at          = nil
    @snapshot.rejected_at          = nil
    @snapshot.snapshot_diff.try(:destroy!)
    @snapshot.snapshot_diff        = nil
    @snapshot.save! # triggers the comparison via after_commit hook

    redirect_to @snapshot, notice: t(:snapshot_recompared)
  end

  private

  def set_snapshot
    @snapshot = Snapshot.find(params[:id])
  end
end
