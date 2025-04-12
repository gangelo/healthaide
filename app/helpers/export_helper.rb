module ExportHelper
  def pretty_json(hash)
    json_string = JSON.pretty_generate(hash)
    content_tag(:pre, json_string, class: "bg-gray-100 p-4 rounded overflow-auto text-sm")
  end
end
