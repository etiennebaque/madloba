module User::LocationFormHelper

  # Get all the areas for the location form partial.
  def areas
    Area.all.select(:id, :name, :latitude, :longitude)
  end


end
