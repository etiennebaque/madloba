Feature: Create a new ad

@javascript
Scenario: Create successfully a new ad with an anonymous user
  Given I am an anonymous user
  And I go to create a new ad page
  Then I should see 'New ad'
  When I fill in 'ad[title]' with 'Ad title example'
  And I choose 'I'm giving away items.'
  And I add an item
  And I click on 'Create a new item'
  Then I should see 'Write a new item and select its category'

