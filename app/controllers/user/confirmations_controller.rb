class User::ConfirmationsController < Devise::ConfirmationsController

  layout 'home'

  def new
    super
  end
end
