module User::LocationFormHelper

  # Get all the areas for the location form partial.
  def areas
    all_areas = Rails.cache.fetch(CACHE_AREAS) {Area.select(:id, :name, :bounds)}
    return all_areas.collect{|d| [d.name, d.id] }
  end

  # Get the areas bounds, when localizing areas on map.
  def areas_bounds
    all_areas = Rails.cache.fetch(CACHE_AREAS) {Area.select(:id, :name, :bounds)}
    results = {}
    all_areas.each do |d|
      results[d.id] = d.bounds
    end
    return results
  end

end
