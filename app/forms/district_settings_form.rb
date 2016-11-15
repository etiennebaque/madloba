class DistrictSettingsForm < ApplicationForm
  include MapHelper

  DISTRICT_ATTRIBUTES = [:area_type, :area_length]
  attr_accessor(*(DISTRICT_ATTRIBUTES))

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
    result = {}
    DISTRICT_ATTRIBUTES.each do |attr|
      result[attr] = self.send(attr).present? ? self.send(attr) : ''
    end
    result
  end

end