class User::LocationsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :authenticate_user!
  before_action :requires_user
  before_action :is_location_controller
  after_action :verify_authorized
  after_action :update_ad_json, only: [:update]

  include ApplicationHelper

  def show
    @location = Location.includes(:ads => :item).includes(:district).where(id: params[:id]).first!
    authorize @location
    getMapSettings(@location, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)
    render 'location'
  end

  def new
    @location = Location.new
    authorize @location
    getMapSettings(@location, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)

    render 'location'
  end

  def create
    @location = Location.new(location_params)
    @location.user = current_user
    authorize @location

    getMapSettings(@location, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)

    if @location.save
      flash[:new_name] = @location.name
      redirect_to edit_user_location_path(@location.id)
    else
      render 'location'
    end
  end

  def edit
    @location = Location.includes(ads: :items).includes(:district).where(id: params[:id]).first!

    authorize @location

    if @location.is_area
      getMapSettings(@location, HAS_CENTER_MARKER, CLICKABLE_MAP_AREA_MARKER)
    else
      getMapSettings(@location, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)
    end

    render 'location'
  end

  def update
    @location = Location.find(params[:id])
    authorize @location

    # Reformating latitude and longitude, if needed, so they match the required scale (ie latitude{7,5} and longitude{8,5})
    if location_params['latitude'] && location_params['longitude']
      newLat = BigDecimal.new(location_params['latitude'])
      location_params['latitude'] = newLat.round(5, :up)
      newLon = BigDecimal.new(location_params['longitude'])
      location_params['longitude'] = newLon.round(5, :up)
    end

    if @location.is_area
      getMapSettings(@location, HAS_CENTER_MARKER, CLICKABLE_MAP_AREA_MARKER)
    else
      getMapSettings(@location, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)
    end

    if @location.update(location_params)

      if location_params['loc_type'] != 'district'
        @location.district = nil
        @location.save
      end

      flash[:name] = @location.name
      redirect_to edit_user_location_path
    else
      render 'location'
    end
  end

  def destroy
    @location = Location.find(params[:id])
    authorize @location
    deleted_location_name = @location.name

    if @location.destroy
      flash[:success] = t('admin.location.location_deleted', deleted_location_name: deleted_location_name)
      redirect_to user_managerecords_path
    else
      render 'location'
    end

  end

  private

  def location_params
    params.require(:location).permit(:name, :street_number, :address, :postal_code, :province, :city, :latitude, :longitude, :phone_number, :website, :description, :loc_type, :district_id)
  end

  # Updates the relevant ads marker_info (jsonb)
  def update_ad_json
    location = Location.find(params[:id])
    Ad.where(location_id: location.id).each do |ad|
      ad.marker_info['lat'] = location.latitude
      ad.marker_info['lng'] = location.longitude
      ad.save
    end
  end

  # This boolean is to be used on the location form partial. We don't want the "Enter new location" header to appear,
  # when page loaded from a location controller action.
  def is_location_controller
    @is_location_edit = true
  end

end

