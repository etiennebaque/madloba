require 'test_helper'

class Admin::LocationControllerTest < ActionController::TestCase

  def setup
    @controller = Admin::LocationsController.new
  end

  test "should get location #1 and correct view" do
    get(:show, {'id' => "1"})
    assert_response :success
    assert_template layout: "layouts/admin"
    assert_template "admin/show_location"
  end

  test "should create a new location" do
    assert_difference('Location.count') do
      post :create, location: {name: 'New location', address: 'test street', postal_code: '123456', city: 'Ottawa'}
    end

    assert_redirected_to edit_admin_location_path(assigns(:location))
  end

  test "should edit location #1" do
    location = locations(:cambridge)
    get(:edit, {'id' => "1"})
    patch :update, id: location.id, location: {name: 'updated location name'}

    assert_redirected_to edit_admin_location_path(assigns(:location))

    location = Location.find(1)
    assert_equal 'updated location name', location.name

  end

  test "should delete this new location" do
    location_to_delete_id = Location.count
    assert_difference('Location.count', -1) do
      post :destroy, id: location_to_delete_id
    end
    assert_redirected_to admin_records_path
  end

end
