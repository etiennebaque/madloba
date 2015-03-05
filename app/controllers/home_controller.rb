class HomeController < ApplicationController
  layout 'home'

  include ApplicationHelper


  # --------------------------------------
  # Method for the main screen (home page)
  # --------------------------------------
  def index
    # Initializations
    @mapSettings = {}
    @location_search_refinement_to_display = nil
    @error_location_message = nil
    selected_item_ids = nil

    # We need to see if we have a navigation state.
    # If we do, that will impact what will be displayed on the map.
    if params[:cat]
      cat_nav_state = params[:cat].split(" ")
    end

    # Initializing the map, in relation to its center, defined in the settings table.
    @mapSettings = getMapSettings(nil, HAS_NOT_CENTER_MARKER, NOT_CLICKABLE_MAP)

    # Getting all the needed settings to load the page
    settings_records = Setting.where(key: %w(description area_length area_type contact_email facebook twitter pinterest
                                     link_one_label link_one_url link_two_label link_two_url
                                     link_three_label link_three_url link_four_label link_four_url))

    # Initializing links, and social media information, for the footer of the home page.
    settings = get_footer_info(settings_records)

    # We check if the user searched for an item and/or a location
    if params[:item] && params[:item] != ''
      # An item is being searched.
      searched_item = params[:item]
      selected_item_ids = Item.joins(:ads).where("name LIKE '%#{searched_item}%'").pluck(:id).uniq
    end

    if (params[:lat] && params[:lon])
        # It's a location-based search
        @mapSettings['page'] = 'searchedLocationOnHome'
        # The center of the map is now represented by the searched location.
        @mapSettings['lat'] = params[:lat]
        @mapSettings['lng'] = params[:lon]

        if session['locations'] && session['locations'].any?
          # We have to find the index where the current location matches the propositions that was matched.
          propositions = session['locations']
          index = 0
          while (propositions[index]['lat'] != params[:lat] || propositions[index]['lon'] != params[:lon]) && (index < propositions.length-1)
            index += 1
          end
          if index == propositions.length
            current_location = t('home.default_current_loc')
          else
            current_location = propositions[index]['display_name']
          end
        else
          # there was no search beforehand, we need to find the address, based on the given latitude and longitude, as parameters.
          current_location = getAddressFromGeocodes(params[:lat], params[:lon])
          if !current_location
            current_location = 'This is your current location.'
          end
        end

        @mapSettings['searched_address'] = current_location
        @location_search_refinement_to_display = current_location

    end

    # Defining all the categories attached to an item.
    if selected_item_ids
      # We select here only the categories, based on the items found after a search.
      @categories = Category.joins(items: :ads).where("items.id IN (?)", selected_item_ids).uniq
    else
      # We select the categories related to all available items
      @categories = Category.joins(items: :ads).uniq
    end

    # Queries to get ads to be displayed on the map, based on their locations
    # First, we get the ads tied to an exact location.
    @locations_exact = Location.search('exact', cat_nav_state, searched_item, selected_item_ids, params[:q])

    area_types = settings['area_type'].split(',')
    if area_types.include?('postal')
      # If the users have the possiblity to post ad linked to a postal code, we get here these type of ads.
      @locations_postal = Location.search('postal', cat_nav_state, searched_item, selected_item_ids, params[:q])
    end
    if area_types.include?('district')
      # If the users have the possiblity to post ad linked to a pre-defined district, we also get here these type of ads.
      @locations_district = Location.search('district', cat_nav_state, searched_item, selected_item_ids, params[:q])
    end

    # Getting a hash that matches areas to their respective latitude and longitudes.
    if area_types.include?('postal') || area_types.include?('district')
      @area_geocodes = define_area_geocodes
    end

  end


  # -------------------------
  # Method for the About page
  # -------------------------
  def about
    settings = Setting.where(key: %w(contact_email description))
    settings.each do |setting|
      if setting['key'] == 'description' && setting['value'] != ''
        @website_description_paragraph = setting['value'].split(/[\r\n]+/)
      end
      if setting['key'] == 'contact_email' && setting['value'] != ''
        @contact_email = setting['value']
      end
    end

    render 'home/about'
  end


  private


  # Creates a hash with the link and the label of one "Useful link",
  # that appears at the center of the home page footer.
  def get_link(label, url)
    if label != '' && url != ''
      return {label: label, url: url}
    end
  end

  # This method creates the final longitudes and latitudes for each area to be displayed on the map.
  def define_area_geocodes
    area_geocodes = {}
    if (@locations_postal && @locations_postal.length > 0)
      @locations_postal.each do |area, locations|
        total_latitude = 0.0
        total_longitude = 0.0
        count = 0
        locations.each do |location|
          total_latitude += location.latitude.to_f
          total_longitude += location.longitude.to_f
          count += 1
        end
        area_geocodes[area] = {'latitude' => total_latitude / count, 'longitude' => total_longitude / count}
      end
    end

    if (@locations_district && @locations_district.length > 0)
      districts = District.where(id: @locations_district.keys)
      districts.each do |district|
        area_geocodes[district.id] = {'name' => district.name, 'latitude' => district.latitude, 'longitude' => district.longitude}
      end
    end

    return area_geocodes
  end

  # Get information ready for the footer of the home page
  # (eg. Website description, contact email, social media links... )
  # Also returns a settings hash, that will be needed for the rest of HomeController#index execution.
  def get_footer_info(settings_records)
    @social_medias = []
    settings = {}
    settings_records.each do |setting|
      if %w(facebook twitter pinterest).include? setting['key']
        # Website's social media
        social = {}
        if setting['value'] != ''
          social['name'] = setting['key']
          if setting['key'] == 'twitter'
            social['url'] = "http://twitter.com/#{setting['value']}"
          else
            social['url'] = "http://#{setting['value']}"
          end
          @social_medias << social
        end
      elsif setting['key'] == 'description'
        # Website description
        @website_description_paragraph = []
        if setting['value'] && setting['value'].length > 0
          @website_description_paragraph = setting['value'].split(/[\r\n]+/)
        end
      elsif setting['key'] == 'contact_email'
        @contact_email = setting['value']
      else
        # Settings hash
        settings[setting['key']]=setting['value']
      end
    end

    # Useful links, for the footer section.
    @links = []
    @links << get_link(settings['link_one_label'], settings['link_one_url'])
    @links << get_link(settings['link_two_label'], settings['link_two_url'])
    @links << get_link(settings['link_three_label'], settings['link_three_url'])
    @links << get_link(settings['link_four_label'], settings['link_four_url'])

    return settings
  end

end
