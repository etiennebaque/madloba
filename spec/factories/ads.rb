# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :ad do |f|
    f.title { Faker::Name.title }
    f.description { Faker::Lorem.sentence }
    f.is_giving { [true, false].sample}
    f.is_username_used { [true, false].sample}
    f.expire_date { Date.new(2100,1,1) }

    location
    user

  end

  factory :ad_with_items, parent: :ad do
    ad_items {[build(:ad_with_first_item)]}
  end

  factory :ad_with_other_items, parent: :ad do
    ad_items {[build(:ad_with_second_item)]}
  end

  factory :invalid_ad_no_item, parent: :ad do |f|
    ad_items {[]}
  end

  factory :invalid_ad_image_too_big, parent: :ad do |f|
    f.image {}
  end

  factory :invalid_ad, parent: :ad do |f|
    f.title nil
  end

end
