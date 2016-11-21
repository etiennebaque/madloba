class AreaSettingsForm < ApplicationForm
  include MapHelper

  def initialize
    #init_map_settings
    #init_areas

    #self.page = 'areasettings'
  end

  def init_areas
    areas = Area.all.select(:id, :name, :bounds)
    self.areas = []
    areas.each do |d|
      if d.bounds.present?
        bounds = JSON.parse(d.bounds)
        bounds['properties']['id'] = d.id
        bounds['properties']['name'] = d.name
        self.areas.push(bounds)
      end
    end
  end

  def to_hash
    {}
  end

end