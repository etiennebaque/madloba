class MapAdInfo < MapInfo

  AD_INFO_ATTRIBUTES = [:ad_show, :popup_message, :area]

  attr_accessor(*(MAP_INFO_ATTRIBUTES+AD_INFO_ATTRIBUTES))

  def initialize(ad)
    super()
    ad_location = ad.location
    items = ad.items

    if ad_location.area?
      # Getting information for this ad based that's based on area-only location
      self.popup_message = items.map(&:capitalized_name).join(', ')
      self.area = ad_location.area
    else
      # Getting information as an exact address location
      self.ad_show = []
      items.each {|item| self.ad_show << {icon: item.category.icon, color: item.category.marker_color, item_name: item.name}}
    end

    self.latitude = ad_location.latitude
    self.longitude = ad_location.longitude
    self.zoom_level = CLOSER_ZOOM_LEVEL
  end

  def attributes_to_read
    MAP_INFO_ATTRIBUTES+AD_INFO_ATTRIBUTES
  end
end