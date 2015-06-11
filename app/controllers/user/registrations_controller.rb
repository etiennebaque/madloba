class User::RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def update
    super
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    if request.referer.include? 'setup'
      setup_done_path
    else
      root_path
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :password, :password_confirmation, :role)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :password, :password_confirmation, :current_password, :role)
  end

end
