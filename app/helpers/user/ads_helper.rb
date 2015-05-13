module User::AdsHelper

  # All items linked to all ads needed for the type-ahead functionality, in the search bar. (it's not necessarily all the existing items)
  def all_ads_items
    Ad.joins(:items).pluck(:name).uniq
  end

  # All items from the database, for the item field, in the New ad form
  def all_items
    Item.pluck(:name)
  end

  # Checks if current user owns this ad.
  def is_owning(ad)
    current_user && current_user.owns_ad(ad)
  end

  # Checks if image upload is allowed
  def can_upload_image
    image_storage = Rails.cache.fetch(CACHE_IMAGE_STORAGE) {Setting.find_or_create_by(key: 'image_storage').value}
    return (image_storage == IMAGE_ON_SERVER || image_storage == IMAGE_AMAZON_S3)
  end

  def publisher_name(ad)
    publisher_name = ''
    ad_user = ad.user
    if ad.is_anonymous
      publisher_name = ad_user.username
    else
      publisher_name = "#{ad_user.first_name} #{ad_user.last_name}"
    end
    return publisher_name
  end

  # When an ad-related page loads, the associated image might still be processed, or being uploaded to S3.
  # This method checks if the normal image is available yet.
  def is_image_available(ad)
    return ad.image && (ad.image.versions)[:normal].file.present? && (ad.image.versions)[:normal].file.exists?
  end

  # Getting the maximum number of days of publication, before ad expires.
  def max_expire_days
    Setting.where(key: 'ad_max_expire').pluck(:value).first
  end

  # Create / Edit ad: Tag used to generate the html code for the item name field, when adding up an item to the ad.
  def new_item_name_tag
    tag :input, id: 'ad_item', class: 'form-control ad_item typeahead', style: 'vertical-align: bottom;', size: 25, type: 'text', autocomplete: 'off'
  end

  # Create / Edit ad: Tag used to generate the html code for the item category drop down, when adding up an item to the ad.
  def new_item_category_tag
    categories = Category.pluck(:name, :id)
    return content_tag :select, options_for_select(categories, nil), id: 'category', class: 'form-control', style: 'vertical-align: bottom;'
  end

  # Create / Edit ad: Tag used to generate the html code for the quantity text field, when adding up an item to the ad.
  def new_item_quantity_tag
    quantities = [['-', '-']]
    (1..10).each {|n| quantities << [n.to_s,n.to_s]}
    quantities << ['10+', '10+']
    return content_tag :select, options_for_select(quantities, nil), id: 'new_quantity_text', class: 'form-control', style: 'vertical-align: bottom;'
  end

  # Create / Edit ad: Creates a hash of categories, for the item table
  def category_hash
    result = {}
    Category.pluck(:name, :id).each{|cat| result[cat[1]] = cat[0]}
    return result
  end

end
