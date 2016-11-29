Given(/^I am an anonymous user$/) do
  current_driver = Capybara.current_driver
  begin
    Capybara.current_driver = :rack_test
    page.driver.submit :delete, '/user/logout', {}
  ensure
    Capybara.current_driver = current_driver
  end
end

Given(/^I am a signed ([^"]*)$/) do |user_type|
  @user = FactoryGirl.create(user_type.to_sym)
  visit root_path
  page.find('#popover').click
  step("I fill in 'user[email]' with '#{@user.email}'")
  step("I fill in 'user[password]' with '#{@user.password}'")
  click_button 'Sign in'
end