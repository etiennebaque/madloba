require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe Ad, :type => :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:ad)).to be_valid
  end

  it 'is linked to a location' do
    expect(FactoryGirl.build(:ad)).to belong_to(:location)
  end

  it 'is linked to an item' do
    expect(FactoryGirl.build(:ad)).to belong_to(:item)
  end

  it 'is invalid without a title' do
    expect(FactoryGirl.build(:ad, title: nil)).not_to be_valid
  end

  it 'is invalid without a number of items' do
    expect(FactoryGirl.build(:ad, number_of_items: nil)).not_to be_valid
  end

  it 'is invalid without a linked location' do
    expect(FactoryGirl.build(:ad, location: nil)).not_to be_valid
  end

  it 'is invalid without a linked item' do
    expect(FactoryGirl.build(:ad, item: nil)).not_to be_valid
  end

  it 'is invalid without a description' do
    expect(FactoryGirl.build(:ad, description: nil)).not_to be_valid
  end

  it 'is invalid without a is_giving boolean' do
    expect(FactoryGirl.build(:ad, is_giving: nil)).not_to be_valid
  end

end
