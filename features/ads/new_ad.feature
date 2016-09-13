Feature: Create a new ad

@javascript
Scenario: Create successfully a new ad with an anonymous user
  Given I am an anonymous user
  And I go to create a new ad page
  Then I should see 'New ad'
  And I should see 'Create an account or sign in now before publishing your ad'
  And I should see 'Location name'
  When I fill in 'ad[title]' with 'Ad title example'
  And I choose 'I'm giving away items.'
  And I add an item
  And I click on 'Create a new item'
  Then I should see 'Write a new item and select its category'
  When I fill in field with class 'ad-create-item-field' with 'Thing'
  And I fill in 'ad[description]' with 'This is a ad description'
  And I fill in 'ad[location_attributes][name]' with 'My shop'
  And I choose 'by exact address'
  And I fill in 'ad[location_attributes][street_number]' with '250'
  And I fill in 'ad[location_attributes][address]' with 'Gladstone avenue'
  And I fill in 'ad[location_attributes][postal_code]' with 'K2P0Y6'
  And I search for this place
  And I wait 5 seconds
  Then I should see 'Click on the map to locate your exact address'
  When I click somewhere on the map
  Then I should get new geocodes

