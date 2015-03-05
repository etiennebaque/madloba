# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :ad do |f|
    f.title { Faker::Name.title }
    f.number_of_items { Faker::Number.number(1) }
    f.description { Faker::Lorem.sentence }
    f.is_giving { [true, false].sample}
    f.is_anonymous { [true, false].sample}
    f.expire_date { DateTime.strptime('2020-02-02', '%Y-%m-%d') }

    location
    item
    user

  end

  factory :invalid_ad, parent: :ad do |f|
    f.title nil
    f.location nil
    f.item nil
  end

end
