module User::AdsHelper

  # All items linked to all ads needed for the type-ahead functionality, in the search bar. (it's not necessarily all the existing items)
  def all_ads_items
    Ad.joins(:item).pluck(:name).uniq
  end

  # All items from the database, for the item field, in the New ad form
  def all_items
    Item.pluck(:name)
  end

  # display user's locations, to allow them to tie existing one to an ad.
  def user_locations
    current_user.locations
  end

  # check if current user owns this ad.
  def is_owning(ad)
    current_user && current_user.owns_ad(ad)
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

end
