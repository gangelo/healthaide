# frozen_string_literal: true

module Icons
  class SearchComponent < BaseComponent
    def initialize(size_class: nil, **options)
      super(**options)
      @size_class = size_class || "h-6 w-6"
    end

    private

    attr_reader :size_class
  end
end
