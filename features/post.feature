Feature: Create a new post

@javascript
Scenario: Create successfully a new post with a signed in user
  Given I am a signed user
  And I go to create a new post page
  Then I should see 'New post'
  And I should not see 'Create an account or sign in now before publishing your post'
  And I should see 'Which name would you like to show'
  When I fill in 'post[title]' with 'Post title example'
  And I choose 'I'm giving away items.'
  And I add an item
  And I click on 'Create a new item'
  Then I should see 'Write a new item and select its category'
  When I fill in field with class 'post-create-item-field' with 'Thing'
  And I fill in 'post[description]' with 'This is a post description'
  And I fill in 'post[location_attributes][name]' with 'My shop'
  And I fill in 'post[location_attributes][street_number]' with '250'
  And I fill in 'post[location_attributes][address]' with 'Gladstone avenue'
  And I fill in 'post[location_attributes][postal_code]' with 'K2P0Y6'
  And I search for this place
  And I wait 5 seconds
  Then I should see 'Click on the map to locate your exact address'
  When I click somewhere on the map
  Then I should get new geocodes
  And I fill in 'post[location_attributes][phone_number]' with '111222333'
  And I fill in 'post[location_attributes][website]' with 'google.ca'
  And I fill in 'post[location_attributes][description]' with 'This is how to get here.'
  And I click on 'Create this post!' submit button
  Then I should see 'The post 'Post title example' has been created. You will shortly receive an e-mail, with the new post details.'
  And I should see 'This is how to get here.'
  And I should see '111222333'
  And I should see 'google.ca'

@javascript
Scenario: The new post page with an anonymous user should show relevant field
  Given I am an anonymous user
  When I go to create a new post page
  Then I should see 'New post'
  And I should see 'Create an account or sign in now before publishing your post'
  And I should see 'Location name'
  And I should see 'About you'
  And I should see 'Captcha'

Scenario: I visit a post detail page, after this post has been created.
  Given I am an anonymous user
  And a post exists
  When I go visit that post detail page
  Then I should see 'Back to home page'
  When an area-only post exists
  And  I go visit that post detail page
  Then I should see 'Back to home page'
