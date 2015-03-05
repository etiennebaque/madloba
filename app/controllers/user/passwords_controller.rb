class User::PasswordsController < Devise::PasswordsController
  layout 'home'

  def new
    super
  end

  def edit
    super
  end
end
