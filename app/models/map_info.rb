class MapInfo
  include MapHelper

  MAP_INFO_ATTRIBUTES = [:marker_message, :loc_type, :is_area, :marker_message, :bounds, :has_center_marker,
                         :clickable_map_marker, :areas, :default_marker_icon, :new_marker_icon, :district_color, :postal_code_area_color ]

  attr_accessor(*(MAP_SERVICE_ATTRIBUTES+SETTINGS_ATTRIBUTES+MAP_INFO_ATTRIBUTES))

  NO_CENTER_MARKER_PAGES = ['home','areasettings']

  def initialize(location: nil, center_marker: true, clickable: CLICKABLE_MAP_EXACT_MARKER )
    init_map_settings
    init_map_info_for_(location) if location.present?
    init_other_map_info(center_marker, clickable)
  end

  def init_map_info_for_(location)
    self.loc_type = location.loc_type
    self.marker_message = location.marker_message
    self.is_area = location.is_area
    self.bounds = location.district.bounds if location.district?
  end

  def init_other_map_info(center_marker, clickable)
    self.default_marker_icon = ActionController::Base.helpers.asset_path('images/marker-icon.png')
    self.new_marker_icon = ActionController::Base.helpers.asset_path('images/marker-icon-red.png')
    self.district_color = DISTRICT_COLOR
    self.postal_code_area_color = POSTAL_CODE_AREA_COLOR
    self.has_center_marker = center_marker
    self.clickable_map_marker = clickable
  end

  def to_hash
    result = {}
    attrs = MAP_SERVICE_ATTRIBUTES+SETTINGS_ATTRIBUTES+MAP_INFO_ATTRIBUTES
    attrs.each do |attr|
      result[attr] = self.send(attr)
    end
    result
  end

end