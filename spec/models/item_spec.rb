require 'rails_helper'
#require 'shoulda/matchers'
# - There is a problem using shoulda, there's a conflict with Pundit
# - Read more here: https://github.com/elabs/pundit/issues/145

RSpec.describe Item, :type => :model do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:first_item)).to be_valid
  end

  it 'is linked to one or several posts' do
    #expect(FactoryGirl.build(:item)).to have_many(:posts)
    Item.reflect_on_association(:posts).macro == :has_many
  end

  it 'is linked to a category' do
    #expect(FactoryGirl.build(:first_item)).to belong_to(:category)
    Item.reflect_on_association(:category).macro == :belongs_to
  end

  it 'is invalid without a name' do
    expect(FactoryGirl.build(:first_item, name: nil)).not_to be_valid
  end

  it 'is invalid without a category' do
    expect(FactoryGirl.build(:first_item, category: nil)).not_to be_valid
  end
end
