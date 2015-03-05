require 'test_helper'

class User::BaseControllerTest < ActionController::TestCase
  test "should get managerecords" do
    get :managerecords
    assert_response :success
  end

  test "should get manageusers" do
    get :manageusers
    assert_response :success
  end

  test "should get manageads" do
    get :manageads
    assert_response :success
  end

  test "should get manageprofile" do
    get :manageprofile
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
