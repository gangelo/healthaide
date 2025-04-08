module ApplicationHelper
  def nav_link_class(is_active)
    if is_active
      "rounded-md px-3 py-2 text-sm font-semibold bg-gray-900 text-white ring-1 ring-inset ring-white-700/10"
    else
      "rounded-md px-3 py-2 text-sm font-medium text-gray-300 hover:bg-gray-400 hover:text-black"
    end
  end
end
