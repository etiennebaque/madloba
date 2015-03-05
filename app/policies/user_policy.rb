class UserPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(current_user, model)
    @current_user = current_user
    @user = model
  end

  def index?
  end

  def show?
    @current_user == @user || (@current_user && @current_user.admin?)
  end

  def create?
    new?
  end

  def new?
    @current_user && @current_user.admin?
  end

  def update?
    edit?
  end

  def edit?
    @current_user == @user || (@current_user && @current_user.admin?)
  end

  def destroy?
    return false if @current_user == @user
    (@current_user && @current_user.admin?)
  end

end
