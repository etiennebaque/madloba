#!/bin/bash

#--------------------------------------
# Replace '<path_to_my_app>' by the absolute path of your local Madloba app.
root_app=<path_to_my_app>/

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

cd "$root_app"

secret_key="$(rake secret)"

heroku config:set SECRET_KEY_BASE="$secret_key"
heroku config:set MADLOBA_SMTP_HOST="$smtp_host"
heroku config:set MADLOBA_SMTP_ADDRESS="$smtp_address"
heroku config:set MADLOBA_SMTP_PORT=$smtp_port
heroku config:set MADLOBA_SMTP_USERNAME="$smtp_username"
heroku config:set MADLOBA_SMTP_PASSWORD="$smtp_password"
heroku config:set MADLOBA_SMTP_AUTHENTICATION="$smtp_authentication"
heroku config:set MADLOBA_NOTIFICATION_SENDER="$notification_sender"
heroku config:set MADLOBA_ERROR_SENDER="$error_sender"
heroku config:set MADLOBA_ERROR_RECIPIENTS="$error_recipient"
heroku config:set MADLOBA_S3_KEY="$s3_access_key"
heroku config:set MADLOBA_S3_SECRET="$s3_secret_key"
heroku config:set MADLOBA_S3_REGION="$s3_region"
heroku config:set MADLOBA_S3_BUCKET="$s3_bucket_name"
heroku config:set MADLOBA_IS_ON_HEROKU="true"


echo "-----------------------------------------------------------"
echo "Your Madloba environment variables have been set on Heroku."
echo "-----------------------------------------------------------"
