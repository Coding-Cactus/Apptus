class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # '/ping' for uptime monitoring
  def ping; end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def after_sign_in_path_for(_)
    chats_path
  end

  def after_update_path_for(resource)
    account_path(resource)
  end

  private

  def not_found = raise ActionController::RoutingError, 'Not found'

  def turbo_frame_request? = !request.headers['Turbo-Frame'].nil?
  helper_method :turbo_frame_request?
end
