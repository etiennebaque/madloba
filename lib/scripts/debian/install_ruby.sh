#!/bin/bash

## Install Ruby

#--------------------------------------

current_ruby_version='2.2.2'

#--------------------------------------

rbenv install "$current_ruby_version"
rbenv global "$current_ruby_version"
ruby -v

echo "gem: --no-ri --no-rdoc" > ~/.gemrc
gem install bundler --no-ri --no-rdoc

source ~/.gemrc

echo "------------------------------"
echo "ruby $current_ruby_version has been installed."
echo "------------------------------"

