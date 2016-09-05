class Locations::DistrictLocation < Location

  def self.policy_class
    LocationPolicy
  end

  def area?
    true
  end

  def district?
    true
  end

  def marker_message
    district.name
  end

  def location_type_address
    self.district.name
  end

  def location_type_address_public
    self.district.name
  end

end