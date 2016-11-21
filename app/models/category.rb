class Category < ActiveRecord::Base
  include ActiveModel::Validations

  has_many :items

  validates :name, :marker_color, :icon, presence: true
  validate :marker_icon_unique

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
      url = '/'
      if cat_nav_state.include? self.id.to_s
        # We're dealing with a refinement
        other_cat_ids = cat_nav_state - [self.id.to_s]
        url = "/search?cat=#{other_cat_ids.join('+')}" if (other_cat_ids.length > 0)
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
      url == '/' ? url = "/search?item=#{params[:item]}" : url += "&item=#{params[:item]}"
    end

    if params[:lat] && params[:lon] && params[:loc]
      url == '/' ? url = "/search?" : url += "&"
      url += "/search?lat=#{params[:lat]}&lon=#{params[:lon]}&loc=#{params[:loc]}"
    end

    if params[:q] # user_action represents the 'q' parameter.
      url == '/' ? url = "/search?q=#{params[:q]}" : url += "&q=#{params[:q]}"
    end
    url
  end

  # Sets whether a category link in the guided navigation (home page) is current refinement.
  def is_refinement(params)
    if params[:cat]
      cat_nav_state = params[:cat].split(" ")
    end

    return cat_nav_state && (cat_nav_state.include? self.id.to_s)
  end

  def color_code
    MARKER_COLORS[self.marker_color]
  end

  private

  # Custom validation to check if the chosen marker color / icon duo is unique
  def marker_icon_unique
    other_cat = Category.where(marker_color: marker_color, icon: icon).first
    if !other_cat.nil? && other_cat.id != self.id
      errors.add(:base, I18n.t('admin.category.marker_icon_not_unique'))
    end
  end

end
