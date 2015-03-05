class CustomDeviseMailer < Devise::Mailer

  include ApplicationHelper

  def confirmation_instructions(record, token, opts={})
    @site_name = site_name
    super
  end
end