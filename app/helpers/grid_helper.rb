module GridHelper
  def grid_alternate_row_color(index)
    bg_color = index.odd? ? "bg-gray-100" : "bg-white"
    "#{bg_color} hover:bg-green-100"
  end
end
