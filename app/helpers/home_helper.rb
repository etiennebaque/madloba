module HomeHelper

  # Devise resources related methods
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def user_search_action
    search_action = nil
    user_action = params[:q]
    searched_term = params[:item]

    if user_action && searched_term
      # For the user action's "delete refinement" url, we need to get rid of empty parameters, like 'item=' or 'location='.
      # That's why we have elem[-1], in the delete_if clause.
      if user_action == 'searching'
        search_action = "#{t('home.searching')} #{searched_term}"
      elsif user_action == 'giving'
        search_action = "#{t('home.giving')} #{searched_term}"
      end
    end

    return search_action
  end

end
