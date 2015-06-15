#!/bin/bash

#--------------------------------------

# Replace '<path_to_my_app>' by the absolute path (without slash at the end) of your Madloba app, deployed on your server
# (eg: '/home/username/madloba')
root_app=<path_to_my_app>

#--------------------------------------

secret_key="$(cd $root_app/current/ && bundle exec rake secret)"

echo 'SECRET_KEY_BASE='$secret_key >> $root_app/shared/.rbenv-vars

echo "-----------------------------------------"
echo "Your Madloba secret key has been created."
echo "-----------------------------------------"
