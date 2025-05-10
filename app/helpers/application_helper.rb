module ApplicationHelper
  def nav_link_class(path)
    css_class = "rounded-md px-3 block lg:inline-block py-2 text-sm"
    if active_path?(path)
      "#{css_class} font-semibold text-white ring-1 ring-inset ring-white-700/10"
    else
      "#{css_class} font-medium text-gray-300 hover:bg-gray-400 hover:text-black"
    end
  end

  def titleize(model_object)
    model_object.class.name.underscore.titleize
  end

  def select_include_blank
    "-- Select --"
  end

  private

  # This method will return true if path matches the current_page exactly, or if
  # path is a CRUD path (e.g. /foods/1/edit, /foods/1, /foods/new) and matches
  # the base path of the current path (e.g. /foods, etc.).
  def active_path?(path)
    return true if current_page?(path)

    path.split("/").second == active_base_path
  end

  # This will returns the base path for the current request path. For example:
  # if the request path was /foods/1/edit, /foods/1, /foods/new, etc., "foods"
  # would be returned.
  def active_base_path
    request.path.split("/").second
  end
end
