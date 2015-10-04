# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :district do |f|
    f.name { Faker::Name.title }

    factory :district_with_locations do
      after_create do |district|
        create(:location, district: district)
      end
    end
  end

  factory :invalid_district, parent: :district do |f|
    f.name nil
  end

  factory :new_district do |f|
    f.name nil
  end
end
