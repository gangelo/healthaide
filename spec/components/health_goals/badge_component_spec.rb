require "rails_helper"

RSpec.describe HealthGoals::BadgeComponent, type: :component do
  it "renders the health goal name" do
    render_inline(described_class.new(name: "Weight Loss"))

    expect(page).to have_text("Weight Loss")
  end

  it "renders with default medium size" do
    render_inline(described_class.new(name: "Weight Loss"))

    expect(page).to have_css(".badge-green-md")
  end

  it "renders with small size" do
    render_inline(described_class.new(name: "Weight Loss", size: :sm))

    expect(page).to have_css(".badge-green-sm")
  end

  it "renders with full size" do
    render_inline(described_class.new(name: "Weight Loss", size: :full))

    expect(page).to have_css(".badge-green-full")
  end
end
