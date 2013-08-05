class SnapshotsController < ApplicationController
  # GET /snapshots
  # GET /snapshots.json
  def index
    @snapshots = Snapshot.all

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

  # GET /snapshots/new
  # GET /snapshots/new.json
  def new
    @snapshot = Snapshot.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @snapshot }
    end
  end

  # GET /snapshots/1/edit
  def edit
    @snapshot = Snapshot.find(params[:id])
  end

  # POST /snapshots
  # POST /snapshots.json
  def create
    @snapshot = Snapshot.new(params[:snapshot])

    respond_to do |format|
      if @snapshot.save
        format.html { redirect_to @snapshot, notice: 'Snapshot was successfully created.' }
        format.json { render json: @snapshot, status: :created, location: @snapshot }
      else
        format.html { render action: "new" }
        format.json { render json: @snapshot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /snapshots/1
  # PUT /snapshots/1.json
  def update
    @snapshot = Snapshot.find(params[:id])

    respond_to do |format|
      if @snapshot.update_attributes(params[:snapshot])
        format.html { redirect_to @snapshot, notice: 'Snapshot was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @snapshot.errors, status: :unprocessable_entity }
      end
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
