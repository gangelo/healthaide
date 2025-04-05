module ApplicationHelper
  def nav_link_class(is_active)
    if is_active
      "rounded-md bg-gray-900 px-3 py-2 text-sm font-medium text-white"
    else
      "rounded-md px-3 py-2 text-sm font-medium text-gray-300 hover:bg-gray-700 hover:text-white"
    end
  end
end
