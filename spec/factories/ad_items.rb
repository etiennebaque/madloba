# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :ad_item do
    item
    ad
  end

  factory :ad_with_first_item, class: 'AdItem' do
    association :item, factory: :first_item
  end

  factory :ad_with_second_item, class: 'AdItem' do
    association :item, factory: :second_item
  end

end
