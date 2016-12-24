FactoryGirl.define do

  first_marker_color = MARKER_COLORS.keys[0]
  second_marker_color = MARKER_COLORS.keys[1]
  third_marker_color = MARKER_COLORS.keys[2]

  first_icon = ICON_SELECTION[0]
  second_icon = ICON_SELECTION[1]
  third_icon = ICON_SELECTION[2]

  factory :category do |f|
    f.name { Faker::Name.title }
    f.description { Faker::Lorem.sentence }
  end

  factory :first_category, parent: :category do |f|
    f.marker_color { first_marker_color }
    f.icon { first_icon }
  end

  factory :second_category, parent: :category do |f|
    f.marker_color { second_marker_color }
    f.icon { second_icon }
  end

  factory :third_category, parent: :category do |f|
    f.marker_color { third_marker_color }
    f.icon { third_icon }
  end

  factory :invalid_category, parent: :category do |f|
    f.name nil
    f.marker_color nil
    f.icon nil
  end
end
