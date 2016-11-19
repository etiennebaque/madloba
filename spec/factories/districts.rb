# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :area do |f|
    f.name { Faker::Name.title }

    factory :area_with_locations do
      after_create do |area|
        create(:location, area: area)
      end
    end
  end

  factory :invalid_area, parent: :area do |f|
    f.name nil
  end

  factory :new_area do |f|
    f.name nil
  end
end
