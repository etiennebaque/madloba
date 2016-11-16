module User::LocationFormHelper

  # Get all the districts for the location form partial.
  def districts
    all_districts = Rails.cache.fetch(CACHE_DISTRICTS) {District.select(:id, :name, :bounds)}
    return all_districts.collect{|d| [d.name, d.id] }
  end

  # Get the districts bounds, when localizing districts on map.
  def districts_bounds
    all_districts = Rails.cache.fetch(CACHE_DISTRICTS) {District.select(:id, :name, :bounds)}
    results = {}
    all_districts.each do |d|
      results[d.id] = d.bounds
    end
    return results
  end

end
