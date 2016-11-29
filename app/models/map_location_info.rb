class MapLocationInfo < MapInfo

  def initialize(location:)
    super()

    if location.present?
      self.marker_message = location.marker_message
      self.is_area = location.area?
      self.latitude = location.latitude
      self.longitude = location.longitude
    end
  end
end