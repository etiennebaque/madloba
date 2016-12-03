class Area < ActiveRecord::Base

  has_many :locations

  validates :name, :latitude, :longitude, presence: true

  # Color used to draw areas and postal code areas on map
  AREA_COLOR = '#6ca585'
 
end
