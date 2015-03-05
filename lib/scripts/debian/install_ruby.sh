#!/bin/bash

## Install Ruby 2.1.2
rbenv install 2.1.2
rbenv global 2.1.2
ruby -v

echo "gem: --no-ri --no-rdoc" > ~/.gemrc
gem install bundler --no-ri --no-rdoc

source ~/.gemrc

echo "------------------------------"
echo "ruby 2.1.2 has been installed."
echo "------------------------------"

