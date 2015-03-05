require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test "should not save location without name" do
    location = Location.new
    location.city = "Ottawa"
    location.postal_code = "K1R7B5"
    location.address = "324, Cambridge Street North"
    assert_not location.save, "Saved the location without a name"
  end

  test "should not save location without city" do
    location = Location.new
    location.name = "Previous home"
    location.postal_code = "K1R7B5"
    location.address = "324, Cambridge Street North"
    assert_not location.save, "Saved the location without a city"
  end

  test "should not save location without postal code" do
    location = Location.new
    location.name = "Previous home"
    location.city = "Ottawa"
    location.address = "324, Cambridge Street North"
    assert_not location.save, "Saved the location without a postal code"
  end

  test "should not save location without address" do
    location = Location.new
    location.name = "Previous home"
    location.city = "Ottawa"
    location.postal_code = "K1R7B5"
    assert_not location.save, "Saved the location without an address"
  end

end
