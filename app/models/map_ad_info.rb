class MapAdInfo < MapInfo

  MAP_AD_INFO_ATTRIBUTES = [:ad_show, :popup_message, :ad_show_is_area]

  attr_accessor(*(MAP_INFO_ATTRIBUTES+MAP_AD_INFO_ATTRIBUTES))

  def initialize(ad)
    super(has_center_marker: true, clickable: NOT_CLICKABLE_MAP)

    self.ad_show_is_area = ad.location.area?
    items = ad.items

    if self.ad_show_is_area
      # Getting information whether it's a postal code area, or a district
      self.popup_message = items.map(&:capitalized_name).join(', ')
    else
      # Getting information as an exact address location
      self.ad_show = []
      items.each {|item| self.ad_show << {icon: item.category.icon, color: item.category.marker_color, item_name: item.name}}
    end

    self.latitude = ad.location.latitude
    self.longitude = ad.location.longitude
    self.zoom_level = CLOSER_ZOOM_LEVEL
  end

  def attributes_to_read
    MAP_INFO_ATTRIBUTES+MAP_AD_INFO_ATTRIBUTES
  end
end