namespace :madloba do

  task install: :environment do
    installer = Installer.new
    installer.install_madloba
  end
end