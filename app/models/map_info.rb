class MapInfo
  include MapHelper

  ATTRIBUTES = [:marker_message, :is_area, :bounds, :areas,
                         :default_marker_icon, :new_marker_icon, :area_color ]

  MAP_INFO_ATTRIBUTES = MAP_SERVICE_ATTRIBUTES+SETTINGS_ATTRIBUTES+ATTRIBUTES

  attr_accessor(*MAP_INFO_ATTRIBUTES)

  NO_CENTER_MARKER_PAGES = ['home','areasettings']

  def initialize
    init_map_settings

    self.default_marker_icon = ActionController::Base.helpers.asset_path('images/marker-icon.png')
    self.new_marker_icon = ActionController::Base.helpers.asset_path('images/marker-icon-red.png')
    self.area_color = Area::AREA_COLOR
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