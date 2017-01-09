class Result

  # HTML for every search result, showing up on the right sidebar, on home page.
  # We'll be using this class until we use a front-end framework like Ember.
  def self.create(post)
    result_html = "<div class='result'>"

    # Link to post title
    result_html += "<div class='post-title'><a href='/posts/#{post.id}'>#{post.title}</a></div>"

    # Address
    icon_class = post.location.area? ? Location::AREA_ADDRESS_ICON : Location::EXACT_ADDRESS_ICON
    address = post.location.full_address
    result_html += "<div class='post-address'><i class='fa #{icon_class}'></i>#{address}</div>"

    # Action
    action = "#{post.action} #{post.item_list}"
    result_html += "<div class='post-items'>#{action}</div>"

    # Description
    description = post.short_description
    result_html += "<div class='post-description'>#{description}</div>"

    result_html += "</div>"
    result_html
  end


end