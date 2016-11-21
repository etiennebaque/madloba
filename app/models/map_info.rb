class MapInfo
  include MapHelper

  ATTRIBUTES = [:marker_message, :is_area, :marker_message, :bounds, :has_center_marker,
                         :clickable_map_marker, :areas, :default_marker_icon, :new_marker_icon, :area_color ]

  MAP_INFO_ATTRIBUTES = MAP_SERVICE_ATTRIBUTES+SETTINGS_ATTRIBUTES+ATTRIBUTES

  attr_accessor(*MAP_INFO_ATTRIBUTES)

  NO_CENTER_MARKER_PAGES = ['home','areasettings']

  def initialize(has_center_marker: true, clickable: CLICKABLE_MAP_EXACT_MARKER)
    init_map_settings

    self.default_marker_icon = ActionController::Base.helpers.asset_path('images/marker-icon.png')
    self.new_marker_icon = ActionController::Base.helpers.asset_path('images/marker-icon-red.png')
    self.area_color = Area::AREA_COLOR
    self.has_center_marker = has_center_marker
    self.clickable_map_marker = clickable
  end

  def to_hash
    result = {}
    attributes_to_read.each do |attr|
      result[attr] = self.send(attr).present? ? self.send(attr) : ''
    end
    result
  end

  protected

  def attributes_to_read
    MAP_INFO_ATTRIBUTES
  end

end