When(/^I wait (\d+) seconds$/) do |number|
  sleep(number.to_i)
end

When (/^I click somewhere on the map$/) do
  find('#map').click
end