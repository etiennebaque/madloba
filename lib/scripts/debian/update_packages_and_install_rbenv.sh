#!/bin/bash

## Necessary updates and installs
sudo apt-get update
sudo apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties

## Install of NodeJS in order to have Capistrano deploying from dev machine.
distro="$(lsb_release -a | grep 'Distributor ID' | cut -f2)"
if [ "$distro" = "Ubuntu" ]; then
    # Ubuntu distro
    curl -sL https://deb.nodesource.com/setup | sudo bash -
    sudo apt-get install -y nodejs
else
    # Debian distro
    sudo apt-get install -y curl
    curl -sL https://deb.nodesource.com/setup | sudo bash -
    sudo apt-get install -y nodejs
fi

## Install rbenv
cd
git clone git://github.com/sstephenson/rbenv.git .rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile

echo "--------------------------------------------------------"
echo "Packages have been updated and rbenv has been installed."
echo "--------------------------------------------------------"

