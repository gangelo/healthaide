class Icons::BaseComponent < ViewComponent::Base
  def initialize(css_class: "h-6 w-6")
    @css_class = css_class
  end

  private

  attr_reader :css_class
end
