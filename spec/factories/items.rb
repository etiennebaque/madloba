# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do

  factory :item do |f|
    f.name { Faker::Name.title }
    category
  end

  factory :first_item, parent: :item do
    association :category, factory: :first_category
  end

  factory :second_item, parent: :item do
    association :category, factory: :second_category
  end

  factory :third_item, parent: :item do
    association :category, factory: :third_category
  end

  factory :invalid_item, parent: :item do |f|
    f.name nil
  end

end
