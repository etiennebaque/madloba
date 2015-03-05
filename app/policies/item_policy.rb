class ItemPolicy < ApplicationPolicy
  attr_reader :user, :item

  def initialize(user, item)
    @user = user
    @item = item
  end

  def index?
    user && user.admin?
  end

  def show?
    user && user.admin?
  end

  def create?
    new?
  end

  def new?
    user && user.admin?
  end

  def update?
    user && user.admin?
  end

  def edit?
    update?
  end

  def destroy?
    user && user.admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
