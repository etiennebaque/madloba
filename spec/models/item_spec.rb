require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe Item, :type => :model do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:first_item)).to be_valid
  end

  it 'is linked to one or several ads' do
    expect(FactoryGirl.build(:item)).to have_many(:ads)
  end

  it 'is linked to a category' do
    expect(FactoryGirl.build(:first_item)).to belong_to(:category)
  end

  it 'is invalid without a name' do
    expect(FactoryGirl.build(:first_item, name: nil)).not_to be_valid
  end

  it 'is invalid without a category' do
    expect(FactoryGirl.build(:first_item, category: nil)).not_to be_valid
  end
end
