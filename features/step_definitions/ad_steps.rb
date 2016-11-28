Given(/^I go to create a new ad page$/) do
  visit new_ad_path
  @latitude = page.find('#ad_location_attributes_latitude', visible: false).value
  @longitude = page.find('#ad_location_attributes_longitude', visible: false).value
end

Then(/^I should see '([^"]*)'$/) do |txt|
  page.should have_content(txt)
end

Then(/^I should not see '([^"]*)'$/) do |txt|
  page.should_not have_content(txt)
end

When(/^I fill in '([^"]*)' with '([^"]*)'$/) do |field, txt|
  fill_in field, with: txt
end

When(/^I fill in field with class '([^"]*)' with '([^"]*)'$/) do |klass, txt|
  find(:css, "input.#{klass}").set(txt)
end

When(/^I choose '([^"]*)'$/) do |radio_label|
  choose(radio_label)
end

When(/^I add an item$/) do
  page.find('.add-item-button').click
end

When(/^I click on '([^"]*)'$/) do |txt|
  click_link(txt)
end

When(/^I click on '([^"]*)' button$/) do |txt|
  find_button(txt).click
end

When (/^I click on 'Create this ad!' submit button$/) do
  page.find('#submit_new_ad').click
end

When(/^I search for this place$/) do
  page.find('#find_geocodes_from_address').click
end

Then(/^I should get new geocodes$/) do
  new_latitude = page.find('#ad_location_attributes_latitude', visible: false).value
  new_longitude = page.find('#ad_location_attributes_longitude', visible: false).value
  new_latitude.should_not be(@latitude)
  new_longitude.should_not be(@longitude)
end

When(/^an ad exists$/) do
  @ad = FactoryGirl.create(:ad_with_items)
end

When(/^an area-only ad exists$/) do
  @ad = FactoryGirl.create(:area_only_ad)
end

When(/^I go visit that ad detail page$/) do
  visit ad_path @ad
end