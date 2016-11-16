class Locations::ExactLocation < Location

  def self.policy_class
    LocationPolicy
  end

  def marker_message
    full_name
  end

  def location_type_address
    full_address
  end

  def location_type_address_public
    full_address
  end

end