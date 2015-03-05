# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category do |f|
    f.name { Faker::Name.title }
    f.description { Faker::Lorem.sentence }
    f.marker_color { MARKER_COLORS.keys.sample }
    f.icon { ICON_SELECTION.sample }

  end

  factory :invalid_category, parent: :category do |f|
    f.name nil
    marker_color nil
    icon nil
  end
end
