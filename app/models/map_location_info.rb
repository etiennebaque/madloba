class MapLocationInfo < MapInfo

  def initialize(location:, has_center_marker: true, clickable: CLICKABLE_MAP_EXACT_MARKER)
    super(has_center_marker: has_center_marker, clickable: clickable)

    if location.present?
      self.marker_message = location.marker_message
      self.is_area = location.area?
      self.bounds = location.district.bounds if location.district?
      self.latitude = location.latitude
      self.longitude = location.longitude
    end
  end
end