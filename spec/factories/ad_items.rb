# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :ad_item do
    ad
  end

  factory :ad_with_first_item, parent: :ad_item do
    item :first_item
  end

end
