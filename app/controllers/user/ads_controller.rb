class User::AdsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :authenticate_user!, except: [:new, :create, :send_message, :show]
  before_action :requires_user, except: [:new, :create, :send_message, :show]
  after_action :verify_authorized, except: [:new, :create, :send_message, :send_message]

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

    get_map_settings_for_ad
  end

  def new
    @ad = Ad.new
    authorize @ad

    @ad.build_location()
    get_map_settings_for_ad
  end

  def create
    @ad = Ad.new(ad_params)
    authorize @ad

    # we tie now the user to the ad (if it is not an anonymous user)
    @ad.user = current_user

    # we tie the chosen location
    if params['location_id'] == '0'
      if params['location_to_update']
        location_to_update = Location.update(params['location_to_update'], ad_location_params)
        @ad.location = location_to_update
      else
        # this is a new location. We need to add it to the database, before tying it to the ad
        new_location = Location.new(ad_location_params, user: current_user, city: site_city)
        new_location.user = current_user
        new_location.city = site_city
        new_location.province = Setting.where(key: 'state').pluck('value').first
        new_location.save
        @ad.location = new_location
      end
      if @ad.location && current_user
        @ad.location.user = current_user
      end
    else
      @ad.location = Location.find(params['location_id'])
    end

    # we define the date when the ad won't be published any longer (see maximum number of days, in Settings table)
    if max_number_days_publish == '0'
      # No limit set for ad expiration. Let's use 2100-01-01 as a default date value
      @ad.expire_date = Date.new(2100,1,1)
    else
      d = Date.today
      @ad.expire_date = d + max_number_days_publish.to_i
    end

    if @ad.save_with_or_without_captcha(current_user)
      flash[:new_ad] = @ad.title
      # Letting the user know when their ad will expire.
      if (max_number_days_publish.to_i > 0)
        flash[:ad_expire] = t('ad.ad_create_expire', day_number: max_number_days_publish, expire_date: @ad.expire_date)
      end

      redirect_to ad_path(@ad.id)

      # Sending email confirmation, about the creation of the ad.
      full_admin_url = "http://#{request.env['HTTP_HOST']}/user/manageads"
      # Reloading the now-created ad, with associated items.
      @ad = Ad.includes(:items).where(id: @ad.id).first
      user_info = {}
      if current_user
        user_info = {email: current_user.email, name: current_user.first_name}
      else
        user_info = {email: @ad.anon_email, name: @ad.anon_name}
      end

      if is_on_heroku
        UserMailer.created_ad(user_info, @ad, full_admin_url).deliver
      else
        # Queueing email sending, when not on heroku.
        UserMailer.delay.created_ad(user_info, @ad, full_admin_url)
      end

    else
      # Saving the ad failed.
      flash[:error_new_ad] = @ad.title
      get_map_settings_for_ad

      render action: 'new'
    end

  end

  def edit
    @ad = Ad.includes(:location => :district).where(id: params[:id]).first!
    authorize @ad
    get_map_settings_for_ad

    render layout: 'admin'
  end

  def update
    @ad = Ad.find(params[:id])
    authorize @ad

    # Performing the update.
    if @ad.update(ad_params)
      flash[:ad_updated] = @ad.title
      redirect_to edit_user_ad_path(@ad.id)
    else
      # Saving the ad failed.
      flash[:error_ad] = @ad.title
      get_map_settings_for_ad
      render layout: 'admin', action: 'edit'
    end

  end

  def destroy
    @ad = Ad.find(params[:id])
    authorize @ad
    deleted_ad_title = @ad.title

    if @ad.destroy
      flash[:success] = t('ad.ad_is_deleted', deleted_ad_title: deleted_ad_title)
      redirect_to user_manageads_path
    else
      # Deleting the ad failed.
      flash[:error_delete_ad] = @ad.title
      get_map_settings_for_ad
      render layout: 'admin', action: 'edit'
    end
  end

  def ad_params
    params.require(:ad).permit(:title, :description, :is_username_used, :location_id, :is_giving,
                               :image, :image_cache, :remove_image, :anon_name, :anon_email, :captcha, :captcha_key,
                               :ad_items_attributes => [:id, :item_id, :_destroy, :item_attributes => [:id, :name, :category_id, :_destroy] ],
                               :location_attributes => [:id, :name, :street_number, :address, :postal_code, :province, :city, :district_id, :loc_type, :latitude, :longitude, :phone_number, :website, :description])
  end

  def ad_location_params
    params.require(:ad).require(:location_attributes).permit(:id, :name, :street_number, :address, :postal_code, :province, :city, :district_id, :loc_type, :latitude, :longitude, :phone_number, :website, :description)
  end

  # This method is called when a user replies and sends a message to another user, who posted an ad.
  # It sends the reply to the user who published this ad.
  def send_message
    message = params[:message]
    @ad = Ad.find(params['id'])

    if current_user == nil && !simple_captcha_valid?
      flash.now[:error] = t('ad.captcha_not_valid')
      get_map_settings_for_ad
      render action: 'show'
    else
      if message && message.gsub(/\s+/, '') != ''
        if @ad.is_anonymous
          # Storing info for message to send to a anonymous publisher
          ad_info = {title: @ad.title, first_name: @ad.anon_name, email: @ad.anon_email}
        else
          # Storing info for message to send to a registered publisher
          ad_info = {title: @ad.title, first_name: @ad.user.first_name, email: @ad.user.email}
        end

        if current_user
          # The message sender is a registered user.
          sender_info = {full_name: "#{current_user.first_name} #{current_user.last_name}" , email: current_user.email}
        else
          # The message sender is an anonymous user.
          sender_info = {full_name: params['name'], email: params['email']}
        end

        if is_on_heroku
          UserMailer.send_message_for_ad(sender_info, message, ad_info).deliver
        else
          UserMailer.delay.send_message_for_ad(sender_info, message, ad_info)
        end
        flash[:success] = t('ad.success_sent')
      else
        flash[:error] = t('ad.error_empty_message')
      end

      redirect_to ad_path(params['id'])
    end
  end

  private

  # Initializes map related info (markers, clickable map...)
  def get_map_settings_for_ad
    if %w(show send_message).include?(action_name)
      getMapSettingsWithSeveralItems(@ad.location, HAS_CENTER_MARKER, NOT_CLICKABLE_MAP, @ad.items)
    else
      getMapSettings(@ad.location, HAS_NOT_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)
    end
  end

end
