class District < ActiveRecord::Base

  has_many :locations

  validates :name, presence: true

  def self.bounds
    districts = District.all.select(:id, :name, :bounds)
    result = []
    districts.each do |d|
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
