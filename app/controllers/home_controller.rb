class HomeController < ApplicationController
  include ApplicationHelper

  # --------------------------------------
  # Method for the main screen (home page)
  # --------------------------------------
  def index
    # Initializing the map, in relation to its center, defined in the settings table.
    @map_settings = MapInfo.new.to_hash

    # Initializing links, and social media information, for the footer of the home page.
    settings = get_footer_info

    # Get items that match the wildcard search
    selected_item_ids = matching_items_for(params)

    if (params[:lat] && params[:lon])
        # The center of the map is now represented by the searched location.
        @map_settings[:latitude] = params[:lat]
        @map_settings[:longitude] = params[:lon]

        current_location, popup_html = current_location_for(params)
        @map_settings[:searched_address] = popup_html
        @location_search_refinement_to_display = current_location
    end

    # Defining all the categories attached to an item.
    if selected_item_ids
      # We select here only the categories, based on the items found after a search.
      @categories = Category.joins(posts: :items).where("items.id IN (?)", selected_item_ids).order('name asc').uniq
    else
      # We select the categories related to all available items
      @categories = Category.joins(posts: :items).order('name asc').uniq
    end

    # Queries to get posts to be displayed on the map, based on their locations
    search_result_objects(params, selected_item_ids)
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

  # ------------------
  # Search result page
  # ------------------
  def results
    id = params[:area].to_i
    @posts = Post.includes(:location, :items).where(locations: {area_id: id})
               .paginate(page: params[:page] || 1, per_page: 10 )

    @area = Area.find(id)
    render 'home/results'
  end

  # Method called when marker on the home page is clicked.
  # Returns the HTML code that will create the popup linked to that marker.
  def show_post_popup
    render json: MarkerPopup.post_popup_for(params['post_id'])
  end

  # Same as above, but when area marker is clicked.
  def show_area_popup
    render json: MarkerPopup.area_popup_for(params['area_id'])
  end

  # From the home page, based on the selected navigation, get the relevant posts.
  def refine_state
    markers, post_results = post_markers_and_results_for(params)
    render json: {markers: markers}
  end

  # Method that gets markers and search results list, after a search is made on home page
  def render_search_results
    results = ''
    markers, post_results = post_markers_and_results_for(params)
    post_results.each do |post|
      results += Result.create(post)
    end

    areas = []
    markers.each do |marker|
      if marker['area'] > 0
        areas << marker['area']
        markers.delete(marker)
      end
    end

    selected_areas = Area.where(id: areas.uniq).select(:id, :name, :latitude, :longitude)

    render json: {markers: markers, areas: selected_areas, results: results, categories: post_results.map{|p| p.category_id.to_s}.uniq}
  end

  private

  def post_markers_and_results_for(params)
    selected_item_ids = matching_items_for(params)
    post_results = Post.search(params, selected_item_ids, nil)
    markers = post_results.pluck(:marker_info).uniq
    [markers, post_results]
  end

  def matching_items_for(params)
    if params[:item].present?
      selected_item_ids = Item.joins(:posts).where('name LIKE ?', "%#{params[:item].downcase}%").pluck(:id).uniq
    end
    selected_item_ids
  end

  def search_result_objects(params, selected_item_ids)
    # Get the posts tied to an exact location.
    post_results = Post.search(params, selected_item_ids, nil)
    @locations_exact = post_results.pluck(:marker_info).uniq

    # Getting a hash that matches areas to their respective latitude and longitudes.
    @areas = Area.all.select(:id, :name, :latitude, :longitude)
  end

  def current_location_for(params)
    # A location search was just performed, with the name of the searched location (given back from Nominatim ws) in it.
    return [params[:loc], MarkerPopup.location_popup_for(params[:loc])] if params.has_key?(:loc)

    # there was no search beforehand, we need to find the address, based on given latitude and longitude.
    current_location = address_from_geocodes(params[:lat], params[:lon])
    current_location = t('home.default_current_loc') if current_location.blank?

    [current_location, MarkerPopup.location_popup_for(current_location)]
  end

  # Creates a hash with the link and the label of one "Useful link",
  # that appears at the center of the home page footer.
  def get_link(label, url)
    if label != '' && url != ''
      return {label: label, url: url}
    end
  end

  # Get information ready for the footer of the home page
  # (eg. Website description, contact email, social media links... )
  # Also returns a settings hash, that will be needed for the rest of HomeController#index execution.
  def get_footer_info
    settings = {}
    Setting.all.each do |setting|
      settings[setting['key']]=setting['value']
    end

    # Useful links, for the footer section.
    link_numbers = %w(one two three four)
    @links = []
    link_numbers.each do |number|
      @links << get_link(settings["link_#{number}_label"], settings["link_#{number}_url"])
    end
    settings
  end

end
