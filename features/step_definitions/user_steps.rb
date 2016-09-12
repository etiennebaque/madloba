Given(/^I am an anonymous user$/) do
  current_driver = Capybara.current_driver
  begin
    Capybara.current_driver = :rack_test
    page.driver.submit :delete, '/user/logout', {}
  ensure
    Capybara.current_driver = current_driver
  end
end
