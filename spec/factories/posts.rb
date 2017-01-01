require 'faker'

FactoryGirl.define do
  factory :post do |f|
    f.title { Faker::Name.title }
    f.description { Faker::Lorem.sentence }
    f.giving { [true, false].sample}
    f.username_used { [true, false].sample}
    f.expire_date { Date.new(2100,1,1) }

    association :category, factory: :first_category

    location
    user

  end

  factory :area_only_post, parent: :post do |f|
    f.post_items {[build(:post_with_second_item)]}
    association :category, factory: :second_category
    f.location { FactoryGirl.create(:area_only_location) }
  end

  factory :post_with_items, parent: :post do |f|
    f.post_items {[build(:post_with_first_item)]}
  end

  factory :post_with_other_items, parent: :post do
    post_items {[build(:post_with_second_item)]}
  end

  factory :invalid_post_no_item, parent: :post do |f|
    post_items {[]}
  end

  factory :invalid_post_image_too_big, parent: :post do |f|
    f.image {}
  end

  factory :invalid_post, parent: :post do |f|
    f.title nil
  end

  factory :post_with_no_user_at_all, parent: :post do |f|
    f.user nil
    f.anon_name nil
    f.anon_email nil
  end

  factory :post_with_anon_user_only, parent: :post do |f|
    f.user nil
    f.anon_name { Faker::Name.name }
    f.anon_email { Faker::Internet.email }
  end
end
