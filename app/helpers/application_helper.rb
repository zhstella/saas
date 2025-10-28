module ApplicationHelper
  def display_author(user)
    return 'Anonymous Student' unless user

    current_user == user ? 'You' : user.anonymous_handle
  end
end
