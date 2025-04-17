module ApplicationHelper
  def nav_link_class(path)
    if active_path?(path)
      "rounded-md px-3 block lg:inline-block py-2 text-sm font-semibold bg-gray-900 text-white ring-1 ring-inset ring-white-700/10"
    else
      "rounded-md px-3 block lg:inline-block py-2 text-sm font-medium text-gray-300 hover:bg-gray-400 hover:text-black"
    end
  end

  def titleize(model_object)
    model_object.class.name.underscore.titleize
  end

  private

  def active_path?(path)
    return true if current_page?(path)

    path.split("/").second == active_base_path
  end

  def active_base_path
    request.path.split("/").second
  end
end
