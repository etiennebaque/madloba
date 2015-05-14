# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :ad do |f|
    f.title { Faker::Name.title }
    f.description { Faker::Lorem.sentence }
    f.is_giving { [true, false].sample}
    f.is_anonymous { [true, false].sample}
    f.expire_date { DateTime.strptime('2020-02-02', '%Y-%m-%d') }

    location
    user
  end

  factory :ad_with_items, parent: :ad do |f|
    f.number_of_items {1}
    #after_create {|ad| create(:ad_with_first_item, ad: ad)}
  end

  factory :invalid_ad_no_item, parent: :ad do |f|
    f.number_of_items {0}
  end

  factory :invalid_ad_image_too_big, parent: :ad do |f|
    f.image {  }
  end

  factory :invalid_ad, parent: :ad do |f|
    f.title nil
    f.location nil
    f.item nil
  end

end
