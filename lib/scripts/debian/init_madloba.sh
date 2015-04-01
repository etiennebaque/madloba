#!/bin/bash

path_to_app=~/madloba

if ([ ! -d "$path_to_app" ]); then
    mkdir "$path_to_app"
fi

if ([ ! -d "$path_to_app/shared" ]); then
    mkdir "$path_to_app/shared"
fi

if ([ ! -d "$path_to_app/shared/config" ]); then
    mkdir "$path_to_app/shared/config"
fi

if ([ ! -f "$path_to_app/shared/config/database.yml" ]); then
    curl https://raw.githubusercontent.com/etiennebaque/madloba/master/config/database.yml > "$path_to_app/shared/config/database.yml"
fi

if ([ ! -f "$path_to_app/shared/config/secrets.yml" ]); then
    curl https://raw.githubusercontent.com/etiennebaque/madloba/master/config/secrets.yml > "$path_to_app/shared/config/secrets.yml"
fi

if ([ ! -f "$path_to_app/shared/.rbenv-vars" ]); then
    cd "$path_to_app/shared" && touch .rbenv-vars
fi

echo "---------------------------------------------------"
echo "Deployment folder for Madloba app has been created."
echo "---------------------------------------------------"