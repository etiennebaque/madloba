#!/bin/bash

#--------------------------------------
# Replace '<path_to_my_app>' by the absolute path (without slash at the end) of your Madloba app, deployed on your server
root_app=<path_to_my_app>

# SMTP settings
smtp_host=yourdomain.com
smtp_address=smtp.example.com
smtp_port=587
smtp_username=user@example.com
smtp_password=password
smtp_authentication=plain

# Your Amazon S3 settings
s3_access_key=your_aws_access_key
s3_secret_key=your_aws_secret_key
s3_region=us-east-1
s3_bucket_name=your_aws_bucket

# Notification sender e-mail
# This is the sender e-mail address the users will see, when they'll receive e-mails from your Madloba app.
notification_sender=noreply@yourdomain.com

# Error notification e-mails
# Those are the sender and recipient e-mail addresses to use, in case a technical problem occurs on your website.
error_sender=sender@yourdomain.com
error_recipient=recipient@yourdomain.com
#--------------------------------------

secret_key="$(cd $root_app/current/ && bundle exec rake secret)"

echo '' >> $root_app/shared/.rbenv-vars
echo '# -----------------------------' >> $root_app/shared/.rbenv-vars
echo '# Madloba environment variables' >> $root_app/shared/.rbenv-vars
echo '# -----------------------------' >> $root_app/shared/.rbenv-vars
echo 'export SECRET_KEY_BASE="'$secret_key'"' >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_SMTP_HOST="'$smtp_host'"' >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_SMTP_ADDRESS="'$smtp_address'"' >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_SMTP_PORT='$smtp_port >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_SMTP_USERNAME="'$smtp_username'"' >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_SMTP_PASSWORD="'$smtp_password'"' >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_SMTP_AUTHENTICATION="'$smtp_authentication'"' >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_NOTIFICATION_SENDER="'$notification_sender'"' >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_ERROR_SENDER="'$error_sender'"' >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_ERROR_RECIPIENTS="'$error_recipient'"' >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_S3_KEY="'$s3_access_key'"' >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_S3_SECRET="'$s3_secret_key'"' >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_S3_REGION="'$s3_region'"' >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_S3_BUCKET="'$s3_bucket_name'"' >> $root_app/shared/.rbenv-vars
echo 'export MADLOBA_IS_ON_HEROKU="false"' >> $root_app/shared/.rbenv-vars
echo '' >> $root_app/shared/.rbenv-vars

echo "--------------------------------------------------------"
echo "Environment variables for Madloba app have been created."
echo "--------------------------------------------------------"
