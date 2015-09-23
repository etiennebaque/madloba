require 'rails_helper'
#require 'shoulda/matchers'
# - There is a problem using shoulda, there's a conflict with Pundit
# - Read more here: https://github.com/elabs/pundit/issues/145

RSpec.describe District, :type => :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:district)).to be_valid
  end

  it 'is linked to one or several locations' do
    #expect(FactoryGirl.build(:district)).to have_many(:locations)
    District.reflect_on_association(:locations).macro == :has_many
  end

  it 'is invalid without a name' do
    expect(FactoryGirl.build(:district, name: nil)).not_to be_valid
  end

end
