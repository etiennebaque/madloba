FactoryGirl.define do

  factory :post_item do
    item
    post
  end

  factory :post_with_first_item, class: 'PostItem' do
    association :item
  end

  factory :post_with_second_item, class: 'PostItem' do
    association :item
  end

end
