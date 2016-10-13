When(/^I wait (\d+) seconds$/) do |number|
  sleep(number.to_i)
end

When (/^I click somewhere on the map$/) do
  #first('.leaflet-tile-loaded').click - Manage to get the map loaded on the page
  page.find('#ad_location_attributes_latitude', visible: false).set '45.12345'
  page.find('#ad_location_attributes_longitude', visible: false).set '-75.12345'
end