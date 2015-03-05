class AdminPolicy < ApplicationPolicy
  attr_reader :user, :admin

  def initialize(user, admin)
    @user = user
    @admin = admin
  end

  def managerecords?
    user.admin?
  end

  def manageusers?
    user.admin?
  end

  def generalsettings?
    user.admin?
  end

  def mapsettings?
    user.admin?
  end

  def areasettings?
    user.admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
