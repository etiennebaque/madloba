require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe User, :type => :model do
  before :each do
    @user = FactoryGirl.build(:user)
  end

  it 'has a valid factory' do
    expect(@user).to be_valid
  end

  it 'is invalid without an e-mail' do
    expect(FactoryGirl.build(:user, email: nil)).not_to be_valid
  end

  it 'is invalid without a first name' do
    expect(FactoryGirl.build(:user, first_name: nil)).not_to be_valid
  end

  it 'is invalid without a last name' do
    expect(FactoryGirl.build(:user, last_name: nil)).not_to be_valid
  end

  it 'is invalid without a username' do
    expect(FactoryGirl.build(:user, username: nil)).not_to be_valid
  end

end