# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ad_item do
    ad nil
    item nil
    is_quantifiable false
    quantity 1
  end
end
