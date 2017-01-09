class MarkerPopup

  # Popup showing when clicking on exact address marker, on the home page.
  # We'll be using this class until we use a front-end framework like Ember.
  def self.post_popup_for(post_id)
    popup_html = ''
    begin
      post = Post.includes(:location, :category, :items).where(id: post_id).first
      title = post.title.length > 40 ? post.title.chomp(a[-3..-1]) + '...' : post.title

      popup_html = "<div style='overflow: auto;'>"

      # Title
      popup_html += "<div class='col-xs-12 title-popup' style='background-color: #{post.category.color_code}'>" +
          "<span>#{title.capitalize}</span></div>"

      if post.image?
        image_tag = ActionController::Base.helpers.image_tag(post.image.normal.url)
        popup_html += "<div class='col-xs-12 image-popup no-padding'>#{image_tag}</div>"
      end

      # Category
      category = "Category: <span style='color:" + post.category.color_code + "';><strong>" + post.category.name + "</strong></span>";
      popup_html += "<div class='col-xs-12' style='margin-top: 15px;'>#{category}</div>"

      # Action (giving away or searching for) + name of items
      post_action = post.giving ? I18n.t('post.giving_away') : I18n.t('post.accepting')
      item_names = post.items.map{|i| i.name.capitalize}.join(', ')

      popup_html += "<div class='col-xs-12'>#{post_action} #{item_names}</div>"

      # Location full address
      popup_html += "<div class='col-xs-12' style='margin: 15px 0px;'>#{post.location.full_address}</div>"

      # "Show details" button
      button = "<a href='/posts/#{post.id}' class='btn btn-info btn-sm no-color'>#{I18n.t('home.show_details')}</a>"
      popup_html += "<div class='col-xs-12 button-popup'>#{button}</div>"

      popup_html += "</div>"

    rescue Exception => e
      puts e
      # An error occurred, we show a error message.
      popup_html = "<i>#{I18n.t('home.error_get_popup_content')}</i>"
    end
    popup_html
  end

  # Popup showing when clicking on area marker, on the home page.
  def self.area_popup_for(area_id)
    popup_html = ''
    begin
      area = Area.includes(locations: {posts: :items}).find(area_id.to_i)
      post_count, item_count = 0, 0

      # Counting items for all posts in this area.
      area.locations.each do |location|
        post_count += location.posts.count
        location.posts.each{|post| item_count += post.items.count}
      end

      message = I18n.t("home.area_marker_message", post_count: post_count, item_count: item_count)

      popup_html = "<div style='overflow: auto;'>"

      # Title
      popup_html += "<div class='col-xs-12 title-popup' style='background-color: #{Area::AREA_COLOR}'>" +
          "<span>#{area.name}</span></div>"

      # Message
      popup_html += "<div class='col-xs-12' style='margin: 15px 0px;'>#{message}</div>"

      # "Show details" button
      button = "<a href='/results?area=#{area_id}' class='btn btn-info btn-sm no-color'>#{I18n.t('home.show_results')}</a>"
      popup_html += "<div class='col-xs-12 button-popup'>#{button}</div>"

      popup_html += "</div>"

    rescue Exception => e
      logger.error e.message
      logger.error e.backtrace.join("\n")
      # An error occurred, we show a error message.
      popup_html = "<i>#{I18n.t('home.error_get_popup_content')}</i>"
    end
    popup_html
  end

  def self.location_popup_for(content)
    popup_html = "<div style='overflow: auto;'>"

    # Title
    popup_html += "<div class='col-xs-12 title-popup' style='background-color: #{Area::AREA_COLOR}'>" +
        "<span>#{I18n.t('home.your_searched_location')}</span></div>"
    # Message
    popup_html += "<div class='col-xs-12' style='margin: 15px 0px;'>#{content}</div>"
    popup_html += "</div>"

    popup_html
  end

end