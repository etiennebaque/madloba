class Area < ActiveRecord::Base

  has_many :locations

  validates :name, presence: true

  # Color used to draw areas and postal code areas on map
  AREA_COLOR = '#6ca585'

  def self.bounds
    areas = Area.all.select(:id, :name, :bounds)
    result = []
    areas.each do |d|
      if d.bounds.present?
        bounds = JSON.parse(d.bounds)
        bounds['properties']['id'] = d.id
        bounds['properties']['name'] = d.name
        result << bounds
      end
    end
    result
  end
 
end
