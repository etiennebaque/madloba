require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  test "should not save category without name" do
    category = Category.new
    category.marker_color = "blue"
    assert_not category.save, "Saved the category without a name"
  end

  test "should not save category without marker color" do
    category = Category.new
    category.name = "Default category"
    assert_not category.save, "Saved the category without a marker color"
  end

end
