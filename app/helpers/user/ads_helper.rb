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

  def new_item_name_tag
    tag :input, id: 'ad_item', class: 'form-control ad_item', size: 30, type: 'text', autocomplete: 'off', data: {provide: 'typeahead'}
  end

  def new_item_category_tag
    content_tag :select, options_for_select(@categories, nil), id: 'category', class: 'form-control'
  end

  def new_item_quantity_tag
    tag 'input', id: 'new_quantity_text', class: 'form-control'
  end

end
