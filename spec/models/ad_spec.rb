require 'rails_helper'
#require 'shoulda/matchers'
# - There is a problem using shoulda, there's a conflict with Pundit
# - Read more here: https://github.com/elabs/pundit/issues/145

RSpec.describe Ad, :type => :model do

  after(:each){
    image_paths = %w(tmp.jpg tmp.txt)
    image_paths.each do |image_path|
      path = Rails.root.join(image_path)
      if File.exist?(path)
        File.delete(path)
      end
    end
  }

  BUFFER = ('a' * 1024).freeze

  it 'has a valid factory' do
    expect(FactoryGirl.build(:ad_with_items)).to be_valid
  end

  it 'is linked to a location' do
    Ad.reflect_on_association(:location).macro == :belongs_to
  end

  it 'is linked to one or several items' do
    Ad.reflect_on_association(:items).macro == :has_many
  end

  it 'is invalid without a title' do
    expect(FactoryGirl.build(:ad, title: nil)).not_to be_valid
  end

  it 'is invalid without a linked location' do
    expect(FactoryGirl.build(:ad, location: nil)).not_to be_valid
  end

  it 'is invalid without a linked item' do
    expect(FactoryGirl.build(:invalid_ad_no_item)).not_to be_valid
  end

  it 'is invalid without a description' do
    expect(FactoryGirl.build(:ad, description: nil)).not_to be_valid
  end

  it 'is invalid without a giving boolean' do
    expect(FactoryGirl.build(:ad, giving: nil)).not_to be_valid
  end

  it 'is invalid with an image too big (more than 5MB)' do
    # Generating a 10M file
    File.open('tmp.jpg', 'wb') { |f| 10.kilobytes.times { f.write BUFFER } }
    expect(FactoryGirl.build(:ad, image: File.open(Rails.root.join('tmp.jpg')))).not_to be_valid
  end

  it 'is invalid if image is not an image file' do
    # Generating a simple text file
    File.open('tmp.txt', 'wb') { |f| f.write BUFFER }
    expect(FactoryGirl.build(:ad, image: File.open(Rails.root.join('tmp.txt')))).not_to be_valid
  end

  it 'is invalid if it has neither user tied to it nor anonymous user' do
    expect(FactoryGirl.build(:ad_with_no_user_at_all)).not_to be_valid
  end

  it 'is valid if it has anonymous name and anonymous email only, no user' do
    expect(FactoryGirl.build(:ad_with_anon_user_only)).not_to be_valid
  end

end
