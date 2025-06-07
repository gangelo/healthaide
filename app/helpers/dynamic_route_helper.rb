module DynamicRouteHelper
  def safe_polymorphic_path(path_array)
    polymorphic_path(path_array)
  rescue ActionController::UrlGenerationError, NoMethodError
    nil
  end

  def polymorphic_route_exists?(path_array)
    safe_polymorphic_path(path_array).present?
  end
end
