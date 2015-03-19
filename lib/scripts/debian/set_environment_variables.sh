#!/bin/bash

#--------------------------------------
# Replace '<path_to_my_app>' by the absolute path of your Madloba app, deployed on your server
root_app=<path_to_my_app>/current/

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

secret_key="$(cd $root_app && bundle exec rake secret)"

echo '' >> ~/.bash_profile
echo '# -----------------------------' >> ~/.bash_profile
echo '# Madloba environment variables' >> ~/.bash_profile
echo '# -----------------------------' >> ~/.bash_profile
echo 'export SECRET_KEY_BASE="'$secret_key'"' >> ~/.bash_profile
echo 'export MADLOBA_SMTP_HOST="'$smtp_host'"' >> ~/.bash_profile
echo 'export MADLOBA_SMTP_ADDRESS="'$smtp_address'"' >> ~/.bash_profile
echo 'export MADLOBA_SMTP_PORT='$smtp_port >> ~/.bash_profile
echo 'export MADLOBA_SMTP_USERNAME="'$smtp_username'"' >> ~/.bash_profile
echo 'export MADLOBA_SMTP_PASSWORD="'$smtp_password'"' >> ~/.bash_profile
echo 'export MADLOBA_SMTP_AUTHENTICATION="'$smtp_authentication'"' >> ~/.bash_profile
echo 'export MADLOBA_NOTIFICATION_SENDER="'$notification_sender'"' >> ~/.bash_profile
echo 'export MADLOBA_ERROR_SENDER="'$error_sender'"' >> ~/.bash_profile
echo 'export MADLOBA_ERROR_RECIPIENTS="'$error_recipient'"' >> ~/.bash_profile
echo 'export MADLOBA_S3_KEY="'$s3_access_key'"' >> ~/.bash_profile
echo 'export MADLOBA_S3_SECRET="'$s3_secret_key'"' >> ~/.bash_profile
echo 'export MADLOBA_S3_REGION="'$s3_region'"' >> ~/.bash_profile
echo 'export MADLOBA_S3_BUCKET="'$s3_bucket_name'"' >> ~/.bash_profile
echo '' >> ~/.bash_profile

echo "--------------------------------------------------------"
echo "Environment variables for Madloba app have been created."
echo "--------------------------------------------------------"
