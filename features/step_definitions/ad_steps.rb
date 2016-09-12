Given(/^I go to create a new ad page$/) do
  visit new_ad_path
end

Then(/^I should see '([^"]*)'$/) do |txt|
  page.should have_content(txt)
end

When(/^I fill in '([^"]*)' with '([^"]*)'$/) do |field, txt|
  fill_in field, with: txt
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