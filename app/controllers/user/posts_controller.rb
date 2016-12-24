class User::PostsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :authenticate_user!, except: [:new, :create, :send_message, :show]
  before_action :requires_user, except: [:new, :create, :send_message, :show]
  after_action :verify_authorized, except: [:new, :create, :send_message, :send_message]
  after_action :serialize_post, only: [:create, :update]

  include ApplicationHelper

  def show
    @post = Post.includes(:location => :area).where(id: params['id']).first!
    authorize @post

    # Redirection to the home page, if this post has expired, expect if current user owns this post.
    if @post.expire_date < Date.today
      if @post.user != current_user
        flash[:error] = t('post.post_has_expired')
        redirect_to root_path
      else
        @your_post_has_expired = true
      end
    end

    get_map_settings_for_post
  end

  def new
    @post = Post.new
    authorize @post
    get_map_settings_for_post
  end

  def create
    @post = Post.new(sanitize_post_params)
    authorize @post

    # we tie now the user to the post (if it is an anonymous user, current_user is nil)
    @post.user = current_user

    if @post.save_with_or_without_captcha(current_user)

      flash[:new_post] = @post.title

      # Letting the user know when their post will expire.
      if (max_number_days_publish.to_i > 0)
        flash[:post_expire] = t('post.post_create_expire', day_number: max_number_days_publish, expire_date: @post.expire_date)
      end

      redirect_to post_path(@post.id)

      # Sending email confirmation, about the creation of the post.
      full_admin_url = "http://#{request.env['HTTP_HOST']}/user/manageposts"
      # Reloading the now-created post, with associated items.
      @post = Post.includes(:items).where(id: @post.id).first
      user_info = {}
      if current_user
        user_info = {email: current_user.email, name: current_user.first_name, is_anon: false}
      else
        user_info = {email: @post.anon_email, name: @post.anon_name, is_anon: true}
      end

      if on_heroku?
        UserMailer.created_post(user_info, @post, full_admin_url).deliver
      else
        # Queueing email sending, when not on heroku.
        UserMailer.delay.created_post(user_info, @post, full_admin_url)
      end

    else
      # Saving the post failed.
      get_map_settings_for_post
      render action: 'new'
    end
  end

  def edit
    @post = Post.includes(:location => :area).where(id: params[:id]).first!
    authorize @post
    get_map_settings_for_post
  end

  def update
    @post = Post.find(params[:id])
    authorize @post

    # Performing the update.
    if @post.update(post_params)
      flash[:post_updated] = @post.title
      redirect_to edit_user_post_path(@post.id)
    else
      # Saving the post failed.
      flash[:error_post] = @post.title
      get_map_settings_for_post
      render action: 'edit'
    end
  end

  def destroy
    @post = Post.find(params[:id])
    authorize @post
    deleted_post_title = @post.title

    if @post.destroy
      flash[:success] = t('post.post_is_deleted', deleted_post_title: deleted_post_title)
      redirect_to user_manageposts_path
    else
      # Deleting the post failed.
      flash[:error_delete_post] = @post.title
      get_map_settings_for_post
      render action: 'edit'
    end
  end

  def post_params
    params.require(:post).permit(:title, :description, :username_used, :location_id, :giving,
                               :image, :image_cache, :remove_image, :anon_name, :anon_email, :captcha, :captcha_key,
                               :post_items_attributes => [:id, :item_id, :_destroy, :item_attributes => [:id, :name, :category_id, :_destroy] ],
                               :location_attributes => [:id, :user_id, :name, :street_number, :address, :province, :postal_code, :city, :area_id, :type, :latitude, :longitude, :phone_number, :website, :description])
  end

  # This method is called when a user replies and sends a message to another user, who posted an post.
  # It sends the reply to the user who published this post.
  def send_message
    message = params[:message]
    @post = Post.find(params['id'])

    if current_user == nil && !simple_captcha_valid?
      flash.now[:error_message] = t('post.captcha_not_valid')
      get_map_settings_for_post
      render action: 'show'
    else
      if message && message.gsub(/\s+/, '') != ''
        if @post.is_anonymous
          # Storing info for message to send to a anonymous publisher
          post_info = {title: @post.title, first_name: @post.anon_name, email: @post.anon_email}
        else
          # Storing info for message to send to a registered publisher
          post_info = {title: @post.title, first_name: @post.user.first_name, email: @post.user.email}
        end

        if current_user
          # The message sender is a registered user.
          sender_info = {full_name: "#{current_user.first_name} #{current_user.last_name}" , email: current_user.email}
        else
          # The message sender is an anonymous user.
          sender_info = {full_name: params['name'], email: params['email']}
        end

        if on_heroku?
          UserMailer.send_message_for_post(sender_info, message, post_info).deliver
        else
          UserMailer.delay.send_message_for_post(sender_info, message, post_info)
        end
        flash[:success] = t('post.success_sent')
      else
        flash[:error] = t('post.error_empty_message')
      end

      redirect_to post_path(params['id'])
    end
  end

  private

  def sanitize_post_params
    sanitized_params = post_params.dup
    if post_params.has_key?(:location_id)
      sanitized_params.delete(:location_attributes)
    end
    sanitized_params
  end

  # Create the json for the 'exact location' post, which will be read to render markers on the home page.
  def serialize_post
    if @post.errors.empty?
      @post.serialize!
    end
  end

  # Initializes map related info (markers, clickable map...)
  def get_map_settings_for_post
    if %w(show send_message).include?(action_name)
      @map_settings = MapPostInfo.new(@post).to_hash
    else
      location = @post.location
      @map_settings = MapLocationInfo.new(location: location).to_hash
    end
  end

end
