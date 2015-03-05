class Setting < ActiveRecord::Base

  def self.maptypes
    %w(osm mapbox mapquest)
  end

end
