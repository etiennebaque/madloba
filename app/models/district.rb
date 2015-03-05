class District < ActiveRecord::Base

  has_many :locations

  validates :name, :latitude, :longitude, presence: true
  validates :latitude , numericality: { greater_than:  -90, less_than:  90 }
  validates :longitude, numericality: { greater_than: -180, less_than: 180 }

end
