module User::AdsHelper

  # All items from the database, for the item field, in the New ad form
  def all_items
    Item.pluck(:name)
  end

  # Checks if current user owns this ad.
  def is_owning(ad)
    current_user && current_user.owns_ad(ad)
  end

  # Checks if anonymous user who posted an ad added their email address.
  # If they did, users will be able to send them a message about this ad.
  def anon_user_puts_email(ad)
    current_user == nil && ad.anon_email != nil
  end

  # Checks if image upload is allowed
  def can_upload_image
    image_storage = Rails.cache.fetch(CACHE_IMAGE_STORAGE) {Setting.find_or_create_by(key: 'image_storage').value}
    return (image_storage == IMAGE_ON_SERVER || image_storage == IMAGE_AMAZON_S3)
  end

  def publisher_name(ad)
    publisher_name = ''
    if ad.is_anonymous
      publisher_name = ad.anon_name
    else
      ad_user = ad.user
      if ad.username_used?
        publisher_name = ad_user.username
      else
        publisher_name = "#{ad_user.first_name} #{ad_user.last_name}"
      end
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

  # If a signed-in user is creating an ad, they will have the choice to create a new location
  # or to choose one of their existing location (registered when creating other ads before).
  def can_choose_existing_locations(current_user)
    current_user != nil && current_user.locations.length > 0
  end

  def expire_date_for(ad)
    return '' if ad.expire_date.to_s == '2100-01-01'

    if Date.today > ad.expire_date
      I18n.t('ad.has_expired', expire_date: ad.expire_date.to_s)
    elsif Date.today < ad.expire_date
      I18n.t('ad.expiration_date', expire_date: ad.expire_date.to_s)
    else
      I18n.t('ad.expires_today')
    end
  end

  def expire_date_for_new_ad
    max_expire_days.to_i > 0 ? t('ad.once_created_expire_html', max_expire_days: max_expire_days) : ''
  end

end
