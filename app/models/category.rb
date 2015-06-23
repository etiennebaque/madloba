class Category < ActiveRecord::Base
  include ActiveModel::Validations

  has_many :items

  validates :name, :marker_color, :icon, presence: true
  validates_uniqueness_of :marker_color, {scope: :icon}

  def icon_name
    self.icon.gsub('fa-','').capitalize.gsub('-',' ')
  end

  def marker_color_hexacode
    MARKER_COLORS[self.marker_color]
  end

  # Method that returns the url to be tied to the category refinement link,
  # in the guided navigation, on the home page.
  def refinement_url(params)

    if params[:cat]
      cat_nav_state = params[:cat].split(" ")
    end

    if cat_nav_state
      # We have a category navigation state. Which means that a "remove refinement" url must be created for each selected category.
      # Also, category urls must take the previous refinements into consideration.
      if cat_nav_state.include? self.id.to_s
        # We're dealing with a refinement
        other_cat_ids = cat_nav_state - [self.id.to_s]
        if (other_cat_ids.length > 0)
          url = "/search?cat=#{other_cat_ids.join('+')}"
        else
          url = '/'
        end
      else
        # We're dealing with a category that was not chosen yet
        url = "/search?cat=#{cat_nav_state.join('+')}+#{self.id}"
      end
    else
      # No navigation state (yet). We create simple refinement url, for each category.
      url = "/search?cat=#{self.id}"
    end

    # We also need to include the search parameters in the remove refinement url, if they exists
    if params[:item] && params[:item] != ''
      if url == '/'
        url = "/search?item=#{params[:item]}"
      else
        url += "&item=#{params[:item]}"
      end
    end
    if params[:lat] && params[:lon] && params[:loc]
      if url == '/'
        url = "/search?lat=#{params[:lat]}&lon=#{params[:lon]}&loc=#{params[:loc]}"
      else
        url += "&lat=#{params[:lat]}&lon=#{params[:lon]}&loc=#{params[:loc]}"
      end
    end
    if params[:q] # user_action represents the 'q' parameter.
      if url == '/'
        url = "/search?q=#{params[:q]}"
      else
        url += "&q=#{params[:q]}"
      end
    end

    return url
  end

  # Sets whether a category link in the guided navigation (home page) is current refinement.
  def is_refinement(params)
    if params[:cat]
      cat_nav_state = params[:cat].split(" ")
    end

    return cat_nav_state && (cat_nav_state.include? self.id.to_s)
  end

end
