require 'highline'

class Installer

  def initialize
    @client = HighLine.new
  end

  def install_madloba
    puts 'Madloba install'
    puts

    type = @client.ask 'test'
    puts type
  end


end