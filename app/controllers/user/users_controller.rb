class User::UsersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :authenticate_user!
  before_action :requires_user
  after_action :verify_authorized

  include ApplicationHelper

  def show
  end

  def new
    @user = User.new
    authorize @user
    @is_adding = true
    @is_managing_user = true
    render 'user'
  end

  def create
    setup_step = Setting.where(key: 'setup_step').pluck(:value).first.to_i
    setup_mode = (setup_step == 1) || Rails.configuration.setup_debug_mode
    setup_mode ? create_first_admin_during_setup : create_new_user
  end

  def create_first_admin_during_setup
    # We're registering the first admin user, during the website setup process.
    # Redirection to the "All done" setup page, after creation of the admin user
    @user = User.new(user_params)
    authorize @user
    @user.skip_confirmation!
    if @user.save
      redirect_to setup_done_path
    else
      redirect_to 'setup/admin'
    end
  end

  def create_new_user
    @user = User.new(user_params)
    authorize @user

    if @user.save
      # We're creating a new user, from the admin panel
      # Redirection to the 'Manage user' edit page (admin panel)
      flash[:new_user] = @user.email
      redirect_to edit_user_user_path(@user.id)
    else
      @is_adding = true
      render 'user'
    end
  end

  def edit
    if (current_user.admin? && params[:id])
      @user = User.find(params[:id])
      @is_managing_user = true
    else
      @user = current_user
      @is_managing_user = false
    end
    authorize @user

    render 'user'
  end

  def update
    if (current_user.admin?)
      @user = User.find(params[:id])
    else
      @user = current_user
    end
    authorize @user
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if (current_user.admin?)
      if @user.update(user_params)
        flash[:user] = @user.email
        redirect_to edit_user_user_path
      else
        render 'user'
      end
    else
      if @user.update_with_password(user_params)
        sign_in @user, :bypass => true
        flash[:user] = @user.email
        redirect_to user_manageprofile_path
      else
        render 'user'
      end
    end

  end

  def destroy
    @user = User.find(params[:id])
    authorize @user

    user_email = @user.email

    if @user.destroy
      flash[:success] = user_email
      redirect_to user_manageusers_path
    else
      render 'user'
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :role, :password, :password_confirmation, :current_password)
  end

end
