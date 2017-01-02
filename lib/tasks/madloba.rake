namespace :madloba do

  task install: :environment do
    installer = Installer.new
    installer.install_madloba
  end

  task reset_dev_db: :environment do
    Rails.cache.delete(CACHE_CHOSEN_LANGUAGE)
    Rails.cache.delete(CACHE_SETUP_STEP)
    puts "Low-level cache has been deleted. Now run following command: "
    puts "- bundle exec rake db:reset db:seed db:seed_fu RAILS_ENV=development"
  end
end