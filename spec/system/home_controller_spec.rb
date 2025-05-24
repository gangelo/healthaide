RSpec.describe "Home" do
  context "when the user visits the home page" do
    it "displays the home page" do
      visit root_path
      expect(page).to have_content("Welcome to HealthAIde")
    end
  end
end
