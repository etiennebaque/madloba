#!/bin/bash

## Install Phusion's PGP key to verify packages
gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
gpg --armor --export 561F9B9CAC40B2F7 | sudo apt-key add -

## Add HTTPS support to APT
sudo apt-get install -y apt-transport-https

# Debian codename
codename="$(lsb_release -a | grep 'Codename' | cut -f2)"

## Add the passenger repository
sudo sh -c "echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger $codename main' >> /etc/apt/sources.list.d/passenger.list"
sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list
sudo apt-get update

## Install nginx and passenger
sudo apt-get install -y nginx-full passenger

# In Nginx config file, uncomment the 'passenger_root' line, and assign the correct Ruby path to 'passenger_ruby'
sudo sed -i 's/# passenger_root/passenger_root/g' /etc/nginx/nginx.conf

ruby_path="$(which ruby)"
line_before_append="$(grep '# passenger_ruby' /etc/nginx/nginx.conf)"

sudo sed -i 's@'"$line_before_append"'@'"$line_before_append"'\n\tpassenger_ruby '"$ruby_path"';@' /etc/nginx/nginx.conf

# Restart Nginx
sudo service nginx restart

echo "---------------------------------------"
echo "Nginx has been installed succeessfully."
echo "---------------------------------------"
