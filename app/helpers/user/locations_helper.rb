module User::LocationsHelper

  def is_adding_new
    action_name == 'new' || action_name == 'create'
  end
end
