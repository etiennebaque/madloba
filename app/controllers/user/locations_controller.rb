class User::LocationsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :authenticate_user!, except: [:retrieve_geocodes]
  before_action :requires_user, except: [:retrieve_geocodes]
  before_action :is_location_controller
  after_action :verify_authorized, except: [:retrieve_geocodes]
  after_action :serialize_posts, only: [:update]

  include ApplicationHelper

  def show
    @location = Location.includes(:posts => :item).includes(:area).where(id: params[:id]).first!
    authorize @location
    @map_settings = MapLocationInfo.new(location: @location)
    render 'location'
  end

  def new
    @location = Location.new
    authorize @location
    @map_settings = MapLocationInfo.new(location: @location).to_hash

    render 'location'
  end

  def create
    @location = Location.new(location_params)
    @location.user = current_user
    authorize @location

    @map_settings = MapLocationInfo.new(location: @location).to_hash

    if @location.save
      flash[:new_name] = @location.name
      redirect_to edit_user_location_path(@location.id)
    else
      render 'location'
    end
  end

  def edit
    @location = Location.includes(posts: :items).includes(:area).where(id: params[:id]).first!

    authorize @location
    @map_settings = MapLocationInfo.new(location: @location).to_hash

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

    @map_settings = MapLocationInfo.new(location: @location).to_hash

    if @location.update(location_params)
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

  def retrieve_geocodes
    location = Location.new(simple_location_params)

    # Getting geocodes for this location.
    address = location.address_geocode_lookup
    response = geocodes_from_address(address)
    exact_found = true

    if response.nil?
      # We're trying to get the geocodes again, but this time without the postal code and the street number
      address = location.address_geocode_lookup(short: true)
      response = geocodes_from_address(address)
      exact_found = false
    end

    if response
      msg_key = exact_found ? 'map_positioned_found' : 'full_not_found_map_position'
      address_found = t("home.#{msg_key}", address: address)
      response['zoom_level'] = CLOSER_ZOOM_LEVEL
      response['status'] = 'ok'
    else
      address_found = t('home.not_found_map_position')
      response = {}
      response['zoom_level'] = Setting.find_by_key('zoom_level').value
      response['status'] = 'not_found'
    end

    response['address_found'] = address_found

    render json: response
  end

  private

  def geocodes_from_address(address)
    geocodes = nil
    response = nominatim_ws_response_for(address)
    if response
      if response[0]
        geocodes = {}
        response_node = response[0]
        if (response_node['lat'] && response_node['lon'])
          geocodes['lat'] = response_node['lat']
          geocodes['lon'] = response_node['lon']
        end
      end
    end
    geocodes
  end

  def location_params
    params.require(:location).permit(:name, :street_number, :address, :postal_code, :province, :city, :country, :latitude, :longitude, :phone_number, :website, :description, :area_id)
  end

  def simple_location_params
    params.permit(:name, :street_number, :address, :postal_code, :province, :city, :country)
  end

  # Updates the relevant posts marker_info (jsonb)
  def serialize_posts
    if @location.errors.empty?
      Post.where(location_id: @location.id).each do |post|
        post.serialize!
      end
    end
  end

  # This boolean is to be used on the location form partial. We don't want the "Enter new location" header to appear,
  # when page loaded from a location controller action.
  def is_location_controller
    @is_location_edit = true
  end

end

