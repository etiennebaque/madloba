class Locations::PostalLocation < Location

  def self.policy_class
    LocationPolicy
  end

  def area?
    true
  end

  def postal?
    true
  end

  def marker_message
    area_code_length = Setting.where(key: %w(area_length)).pluck(:value).first
    "#{postal_code[0..area_code_length.to_i-1]} #{t('ad.area')}"
  end

  def location_type_address
    self.postal_code
  end

  def location_type_address_public
    I18n.t('admin.location.area_name', area_name: self.area)
  end


end