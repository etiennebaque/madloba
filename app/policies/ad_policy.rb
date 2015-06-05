class AdPolicy < ApplicationPolicy
  attr_reader :user, :ad

  def initialize(user, ad)
    @user = user
    @ad = ad
  end

  def owned
    user && (ad.user_id == user.id)
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    new?
  end

  def new?
    true
  end

  def update?
    owned or (user && user.admin?)
  end

  def edit?
    update?
  end

  def destroy?
    owned or (user && user.admin?)
  end

  class Scope < Scope
    def resolve
      if user && user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
