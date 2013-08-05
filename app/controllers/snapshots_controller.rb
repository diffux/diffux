class SnapshotsController < ApplicationController
  # GET /snapshots
  # GET /snapshots.json
  def index
    if params[:url]
      @url = Url.find(params[:url])
      @snapshots = @url.snapshots
    else
      @snapshots = Snapshot.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @snapshots }
    end
  end

  # GET /snapshots/1
  # GET /snapshots/1.json
  def show
    @snapshot = Snapshot.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @snapshot }
    end
  end

  # POST /snapshots
  # POST /snapshots.json
  def create
    url = Url.find(params.delete(:url))
    @snapshot = Snapshot.new(params[:snapshot])
    @snapshot.url = url

    respond_to do |format|
      @snapshot.save!
      format.html { redirect_to @snapshot, notice: 'Snapshot was successfully created.' }
      format.json { render json: @snapshot, status: :created, location: @snapshot }
    end
  end

  # DELETE /snapshots/1
  # DELETE /snapshots/1.json
  def destroy
    @snapshot = Snapshot.find(params[:id])
    @snapshot.destroy

    respond_to do |format|
      format.html { redirect_to snapshots_url }
      format.json { head :no_content }
    end
  end
end
