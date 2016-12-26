class MapPostInfo < MapInfo

  AD_INFO_ATTRIBUTES = [:marker, :popup_message, :area]

  attr_accessor(*(MAP_INFO_ATTRIBUTES+AD_INFO_ATTRIBUTES))

  def initialize(post)
    super()
    post_location = post.location
    items = post.items

    if post_location.area?
      # Getting information for this post based that's based on area-only location
      self.popup_message = post.item_list
      self.area = post_location.area
    else
      # Getting information as an exact address location
      self.marker = post.marker_info
    end

    self.latitude = post_location.latitude
    self.longitude = post_location.longitude
    self.zoom_level = CLOSER_ZOOM_LEVEL
  end

  def attributes_to_read
    MAP_INFO_ATTRIBUTES+AD_INFO_ATTRIBUTES
  end
end