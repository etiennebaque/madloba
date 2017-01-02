class Setting < ActiveRecord::Base

  SOCIAL_MEDIAS = %w(facebook twitter pinterest)

  scope :social_medias, lambda { where key: SOCIAL_MEDIAS}

  def self.maptypes
    %w(open_street_map mapbox mapquest)
  end

  def self.description
    description = Setting.find_by_key(:description)
    description.present? ? description.value.split(/[\r\n]+/) : ''
  end

  def self.contact_email
    Setting.find_by_key(:contact_email)
  end

  def self.value_for(key)
    Setting.where(key: key).first.try(:value)
  end

  def url
    key == 'twitter' ? "http://twitter.com/#{value}" : "http://#{value}"
  end

end
