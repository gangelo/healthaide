# frozen_string_literal: true

module PagyHelper
  include Pagy::Frontend

  # Include any custom helper methods for Pagy here
  def pager_url_for(path:, pager_page:, pager_rows:)
    "#{path}?pager_page=#{pager_page}&pager_rows=#{pager_rows}"
  end
end
