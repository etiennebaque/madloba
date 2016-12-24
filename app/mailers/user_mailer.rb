class UserMailer < ActionMailer::Base
  default from: Rails.application.secrets.notification_email

  include ApplicationHelper

  # When an post is created, this method sends an e-mail to the user who just created it.
  def created_post(user_info, post, url)
    @post = post
    @full_admin_url = url
    @max_expire_days = max_number_days_publish
    @user = user_info
    @site_name = site_name
    mail(to: user_info[:email], subject: t('mailer.new_post_object', site_name: site_name, post_title: post.title))
  end

  # Sends an e-mail to a user, when another user replied to their post, to be in touch with them.
  def send_message_for_post(sender, message, post_info)
    @sender = sender
    @post = post_info
    @site_name = site_name
    @message = message
    mail(to: post_info[:email], reply_to: sender[:email], subject: t('mailer.reply_post_object', post_title: post_info[:title], site_name: site_name))
  end

end
