class User::AdsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :authenticate_user!, except: [:show]
  before_action :requires_user, except: [:show]
  after_action :verify_authorized, except: :checkItemExists

  layout 'home'

  include ApplicationHelper

  def show
    @ad = Ad.includes(:location => :district).where(id: params['id']).first!
    authorize @ad

    # Redirection to the home page, if this ad has expired, expect if current user owns this ad.
    if @ad.expire_date < Date.today
      if @ad.user != current_user
        flash[:error] = t('ad.ad_has_expired')
        redirect_to root_path
      else
        @your_ad_has_expired = true
      end
    end

    # We create a session variable, as a security measure, to make sure that we'll be sending the right message
    # to the right person, if the user chose to do so.
    # This session variable will be read in the 'send_message' method below.
    session["ad_id_#{@ad.id}"] = true

    # For the map settings, we use here the SHOW_AD_FLAG_FOR_MAP, and not the regular
    # AD_FLAG_FOR_MAP. We differentiate here because we don't want a marker to show up
    # on click on map.
    getMapSettingsWithCategory(@ad.location, HAS_CENTER_MARKER, NOT_CLICKABLE_MAP, @ad.item.category)
  end

  def new
    @ad = Ad.new
    authorize @ad
    @ad.number_of_items = 1 # default number of items
    initializeNewForm()
  end

  def create
    @ad = Ad.new(ad_params)
    authorize @ad
    item = Item.find_by_name(params['ad_item'])

    if item
      # this is an existing item. We just need to tie it to the ad
      @ad.item = item
    else
      # we're dealing with a new item. We need to save it first, before tying it to the ad
      new_item = Item.new
      new_item.category = Category.find(params['category'])
      new_item.name = params['ad_item']

      new_item.save
      @ad.item = new_item
    end

    # we tie now the user to the ad
    @ad.user = current_user

    # we tie the chosen location
    if params['location_id'] == '0'
      # this is a new location. We need to add it to the database, before tying it to the ad
      new_location = Location.new(ad_location_params)
      new_location.user = current_user
      new_location.city = site_city
      new_location.province = Setting.where(key: 'state').pluck('value').first

      new_location.save
      @ad.location = new_location
    else
      @ad.location = Location.find(params['location_id'])
    end

    # we define the date when the ad won't be published any longer (see maximum number of days, in Settings table)
    max_expire_days = Setting.where(key: 'ad_max_expire').pluck(:value).first
    if max_expire_days == '0'
      # No limit set for ad expiration. Let's use 2100-01-01 as a default date value
      @ad.expire_date = Date.new(2100,1,1)
    else
      d = Date.today
      @ad.expire_date = d + max_expire_days.to_i
    end

    if @ad.save
      flash[:new_ad] = @ad.title
      redirect_to ad_path(@ad.id)

      # Letting the user know when their ad will expire.
      flash[:ad_expire] = t('ad.ad_create_expire', day_number: max_expire_days, expire_date: @ad.expire_date)

      UserMailer.created_ad(current_user, @ad, request).deliver

    else
      # Saving the ad failed.
      flash[:error_new_ad] = @ad.title
      initializeNewForm()

      render action: 'new'
    end

  end

  def edit
    @ad = Ad.includes(:location => :district).where(id: params[:id]).first!
    authorize @ad
    initialize_areas()
    @categories = Category.pluck(:name, :id)
    getMapSettings(@ad.location, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)

    render layout: 'admin'
  end

  def update
    @ad = Ad.find(params[:id])
    authorize @ad

    params_to_use = nil
    if params['location_id'] != '0'
      params_to_use = ad_params_update
    else
      params_to_use = ad_params
    end

    item = Item.find_by_name(params['ad_item'])
    if item
      # this is an existing item. We just need to tie it to the ad
      @ad.item = item
      params_to_use[:item_id] = item.id
    else
      # we're dealing with a new item. We need to save it first, before tying it to the ad
      new_item = Item.new
      new_item.category = Category.find(params['category'])
      new_item.name = params['ad_item']
      new_item.save
      @ad.item = new_item
      params_to_use[:item_id] = new_item.id
    end

    if @ad.update(params_to_use)
      flash[:ad_updated] = @ad.title
      redirect_to edit_user_ad_path(@ad.id)
    else
      # Saving the ad failed.
      flash[:error_ad] = @ad.title

      @categories = Category.pluck(:name, :id)
      @locations = @ad.user.locations

      initialize_areas()

      getMapSettings(@ad.location, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)

      render layout: 'admin', action: 'edit'
    end

  end

  def destroy
    @ad = Ad.find(params[:id])
    authorize @ad
    deleted_ad_title = @ad.title

    if @ad.destroy
      flash[:success] = "The ad '#{deleted_ad_title}' has been deleted"
      redirect_to user_manageads_path
    else
      # Saving the ad failed.
      flash[:error_delete_ad] = @ad.title

      @categories = Category.pluck(:name, :id)
      getMapSettings(@ad.location, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)

      render layout: 'admin', action: 'edit'
    end
  end

  def ad_params
    params.require(:ad).permit(:title, :number_of_items, :description, :is_anonymous, :location_id, :is_giving, :image, :image_cache, :remove_image, :location_attributes => [:id, :name, :street_number, :address, :postal_code, :province, :city, :district_id, :latitude, :longitude, :phone_number, :website, :description])
  end

  def ad_params_update
    params.require(:ad).permit(:title, :number_of_items, :description, :is_anonymous, :location_id, :is_giving, :image, :image_cache, :remove_image)
  end

  def ad_location_params
    params.require(:ad).require(:location_attributes).permit(:id, :name, :street_number, :address, :postal_code, :province, :city, :loc_type, :latitude, :longitude, :phone_number, :website, :description)
  end

  # Ajax call that checked whether a typed item exist in the database. If it does, we send back the attached category.
  # Otherwise, it'll be a new item, and the category will have to be chosen by the user.
  def checkItemExists
    item_name = params['item_name']
    result = {}

    if item_name && item_name != ''
      # An item is being searched.
      item = Item.where(name: item_name).first
      if item
        # The item already exists in the database
        result['id'] = item.category.id
        result['name'] = item.category.name
      end
    end

    render json: result
  end

  # This method is called when a user replies and sends a message to another user, who posted an ad.
  # It sends the reply to the user who published this ad.
  def send_message
    # We're making sure that we're sending the right message to the right publisher.
    ad_url = request.headers['HTTP_REFERER']
    ad_url_array = ad_url.split('/')
    i = 0
    ad_url_array.each do |url|
      if url == 'ads'
        i += 1
        break
      end
      i += 1
    end

    ad_id = ad_url_array[i]
    if session["ad_id_#{ad_id}"]
      message = params[:message]
      ad = Ad.find(params['id'])

      if message && message.gsub(/\s+/, '') != ''
        UserMailer.send_message_for_ad(current_user, message, ad).deliver
        flash[:success] = t('ad.success_sent')
        session["ad_id_#{ad_id}"] = false
      else
        flash[:error] = t('ad.error_empty_message')
      end
    else
      flash[:error] = t('ad.error_refresh')
    end

    redirect_to ad_path(params['id'])
  end

  private

  def initializeNewForm
    # Initializing category list
    @categories = Category.pluck(:name, :id)

    # Initialize areas (ie districts), when opening the location form.
    initialize_areas()

    @ad.build_location

    # Initializing the map (when creating a new location)
    getMapSettings(@ad.location, HAS_NOT_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)
  end
end
