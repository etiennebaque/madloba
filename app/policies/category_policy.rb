class CategoryPolicy < ApplicationPolicy
  attr_reader :user, :category

  def initialize(user, category)
    @user = user
    @category = category
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
