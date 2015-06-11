class ErrorsController < ApplicationController

  # Redirect to the custom 404 page (error404.html.erb)
  def error404
    render status: :not_found
  end

  # Redirect to the custom 500 page (error500.html.erb)
  def error500
    render status: :internal_server_error
  end
end
