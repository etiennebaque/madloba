Given(/^I go to create a new post page$/) do
  visit new_post_path
  @latitude = page.find('#post_location_attributes_latitude', visible: false).value
  @longitude = page.find('#post_location_attributes_longitude', visible: false).value
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

When (/^I click on 'Create this post!' submit button$/) do
  page.find('#submit_new_post').click
end

When(/^I search for this place$/) do
  page.find('#find_geocodes_from_address').click
end

Then(/^I should get new geocodes$/) do
  new_latitude = page.find('#post_location_attributes_latitude', visible: false).value
  new_longitude = page.find('#post_location_attributes_longitude', visible: false).value
  new_latitude.should_not be(@latitude)
  new_longitude.should_not be(@longitude)
end

When(/^a post exists$/) do
  @post = FactoryGirl.create(:post_with_items)
end

When(/^an area-only post exists$/) do
  @post = FactoryGirl.create(:area_only_post)
end

When(/^I go visit that post detail page$/) do
  visit post_path @post
end