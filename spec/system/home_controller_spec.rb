RSpec.describe "Home" do
  context "when the user visits the home page" do
    it "displays the home page" do
      visit root_path
      expect(page).to have_content("Home")
    end
  end
end
