require 'test_helper'

class User::HomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
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

end
