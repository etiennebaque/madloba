Feature: Navigate in the admin panel

@javascript
Scenario: Be able to go to all admin pages
  Given I am a signed admin
  Then I should see 'Dashboard'
  And I should see 'To-do list'
  When I click on 'Manage records'
  Then I should see 'From here, you can manage the ads posted on the website'
  When I click on 'Manage users'
  Then I should see 'you can manage user accounts'

Scenario: General setting page
  Given I am a signed admin
  And I visit the general settings page
  Then I should see 'Website name'
  When I fill in 'Website name' with 'demo'
  And I fill in 'Website description' with 'this is a demo website'
  And I fill in 'Contact e-mail address' with 'test@test.com'
  And I fill in 'Ad expiration - Max. number of days:' with '60'
  And I fill in 'Facebook page URL:' with 'http://www.facebook.com'
  And I click on 'Save' button
  Then I should see 'The general settings have been updated.'

Scenario: Map setting page
  Given I am a signed admin
  And I visit the map settings page
  Then I should see 'Map type'
  When I select 'OpenStreetMap' in 'Map type'
  And I fill in 'map_settings_form[city]' with 'Paris'
  And I fill in 'map_settings_form[country]' with 'France'
#  TODO
#  And I click on 'Find this city' button
#  Then I should see 'Paris' on the map
  And I select '16' in 'Default zoom level'
  And I click on 'Save' button
  Then I should see 'The map settings have been updated.'




