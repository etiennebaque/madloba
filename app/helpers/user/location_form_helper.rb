module User::LocationFormHelper

  # Get all the areas for the location form partial.
  def areas
    Rails.cache.fetch(CACHE_AREAS) {Area.select(:id, :name, :latitude, :longitude)}
  end


end
