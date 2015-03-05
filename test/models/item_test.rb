require 'test_helper'

class ItemTest < ActiveSupport::TestCase

  test "should not save item without name" do
    item = Item.new
    item.description = "This is an item description"
    assert_not item.save, "Saved the item without a name"
  end

end
