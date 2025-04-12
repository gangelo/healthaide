class Badge::BaseComponent < ViewComponent::Base
  def initialize(name:, size: :md, css_class: "")
    @name = name
    @size = size
    @css_class = css_class
  end

  private

  attr_reader :name, :css_class

  def size
    case @size.to_sym
    when :sm
      "sm"
    when :md
      "md"
    when :full
      "full"
    else
      "md" # Default
    end
  end
end
