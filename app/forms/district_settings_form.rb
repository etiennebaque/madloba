class DistrictSettingsForm < ApplicationForm
  include MapHelper

  def initialize
    #init_map_settings
    #init_districts

    #self.page = 'areasettings'
  end

  def init_districts
    districts = District.all.select(:id, :name, :bounds)
    self.districts = []
    districts.each do |d|
      if d.bounds.present?
        bounds = JSON.parse(d.bounds)
        bounds['properties']['id'] = d.id
        bounds['properties']['name'] = d.name
        self.districts.push(bounds)
      end
    end
  end

  def to_hash
    {}
  end

end