# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do

  factory :item do |f|
    f.name { Faker::Name.title }
    category

    factory :item_with_ads do
      after_create do |item|
        create(:ad, item: item)
      end
    end

  end

  factory :invalid_item, parent: :item do |f|
    f.name nil
  end

end
