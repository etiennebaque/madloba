# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# Settings table, set with default values.
setting_list = [
    %w(app_name Madloba),
    ['description', ''],
    ['contact_email', ''],
    ['link_one_label', ''],
    ['link_one_url', ''],
    ['link_two_label', ''],
    ['link_two_url', ''],
    ['link_three_label', ''],
    ['link_three_url', ''],
    ['link_four_label', ''],
    ['link_four_url', ''],
    %w(chosen_map osm),
    ['map_box_api_key', ''],
    ['mapquest_api_key', ''],
    ['map_center_geocode', ''],
    %w(zoom_level 2),
    ['city', ''],
    ['state', ''],
    ['country', ''],
    ['facebook', ''],
    ['twitter', ''],
    ['pinterest', ''],
    ['postal_code_length', ''],
    ['area_length', ''],
    ['area_type', ''],
    %w(ad_max_expire 90),
    %w(setup_step 1),
    ['image_storage', ''],
    ['language_chosen', 'en']
]

setting_list.each do |setting|
  Setting.create( :key => setting[0], :value => setting[1] )
end

# Create a default category
Category.create(name: 'Default', description: 'Default category.', icon: 'fa-circle', marker_color: 'green')
