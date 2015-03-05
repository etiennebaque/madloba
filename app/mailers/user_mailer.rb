class UserMailer < ActionMailer::Base
  default from: Rails.application.secrets.notification_email

  include ApplicationHelper

  # When an ad is created, this method sends an e-mail to the user who just created it.
  def created_ad(user, ad, request)
    @user = user
    @ad = ad
    @site_name = site_name
    @full_admin_url = "http://#{request.env['HTTP_HOST']}/user/manageads"
    @max_expire_days = Setting.where(key: 'ad_max_expire').pluck(:value).first

    mail(to: @user.email, subject: t('mailer.new_ad_object', site_name: site_name, ad_title: ad.title))
  end

  # Sends an e-mail to a user, when another user replied to their ad, to be in touch with them.
  def send_message_for_ad(sender, message, ad)
    @sender = sender
    @ad = ad
    @site_name = site_name
    @message = message

    mail(to: ad.user.email, reply_to: sender.email, subject: t('mailer.reply_ad_object', ad_title: ad.title, site_name: site_name))
  end
end
