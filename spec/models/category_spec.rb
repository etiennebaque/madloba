require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe Category, :type => :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:category)).to be_valid
  end

  it 'is invalid without a name' do
    expect(FactoryGirl.build(:category, name: nil)).not_to be_valid
  end

  it 'is invalid without a marker color' do
    expect(FactoryGirl.build(:category, marker_color: nil)).not_to be_valid
  end

  it 'is invalid without an icon' do
    expect(FactoryGirl.build(:category, icon: nil)).not_to be_valid
  end

  it 'is invalid if it has same marker color and icon as another category' do
    same_icon_to_use = 'fa-circle'
    same_marker_color_to_use = 'blue'
    category1 = FactoryGirl.create(:category, icon: same_icon_to_use, marker_color: same_marker_color_to_use)
    expect(FactoryGirl.build(:category, icon: same_icon_to_use, marker_color: same_marker_color_to_use)).not_to be_valid

  end

end
