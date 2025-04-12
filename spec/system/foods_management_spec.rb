# frozen_string_literal: true

RSpec.describe "Foods Management", type: :system do
  let(:user) { create(:user, :admin) }

  before do
    # Confirm the user and sign in using helper
    user.confirm
    sign_in user
  end

  describe "creating a new food" do
    let!(:qualifier1) { create(:food_qualifier, qualifier_name: "Organic") }
    let!(:qualifier2) { create(:food_qualifier, qualifier_name: "Fresh") }

    it "creates a new food with existing qualifiers" do
      visit new_food_path

      # Use a more reliable way to find and fill in the food name field
      fill_in "Food name", with: "Banana"

      # Check a qualifier using its ID
      check "qualifier_#{qualifier1.id}"

      click_button "Create Food"

      expect(page).to have_content("Food was successfully created")
      expect(page).to have_content("Banana")
      expect(page).to have_content("Organic")
      expect(page).not_to have_content("Fresh")
    end

    it "creates a new food with a new qualifier" do
      visit new_food_path

      fill_in "Food name", with: "Strawberry"
      fill_in "new_qualifier_name", with: "Seasonal"

      click_button "Create Food"

      expect(page).to have_content("Food was successfully created")
      expect(page).to have_content("Strawberry")
      expect(page).to have_content("Seasonal")
    end

    it "validates food uniqueness with same qualifiers" do
      # Create an existing food with qualifier1
      existing_food = create(:food, food_name: "Apple")
      existing_food.food_qualifiers << qualifier1
      existing_food.save!  # Make sure it's saved

      visit new_food_path

      # Try to create the same food with the same qualifier
      fill_in "Food name", with: "Apple"
      check "qualifier_#{qualifier1.id}"

      click_button "Create Food"

      # Should see an error - this can appear in either the flash message or the form errors
      expect(page).to have_content("A food with this name and the same qualifiers already exists")
    end

    it "allows foods with same name but different qualifiers" do
      # Create an existing food with qualifier1
      existing_food = create(:food, food_name: "Apple")
      existing_food.food_qualifiers << qualifier1

      visit new_food_path

      # Create the same food but with a different qualifier
      fill_in "Food name", with: "Apple"
      check "qualifier_#{qualifier2.id}"

      click_button "Create Food"

      # Should succeed
      expect(page).to have_content("Food was successfully created")
      expect(page).to have_content("Apple")
      expect(page).to have_content("Fresh")
    end
  end

  describe "editing a food" do
    let!(:qualifier1) { create(:food_qualifier, qualifier_name: "Organic") }
    let!(:qualifier2) { create(:food_qualifier, qualifier_name: "Fresh") }
    let!(:food) { create(:food, food_name: "Carrot") }

    before do
      food.food_qualifiers << qualifier1
    end

    it "updates food name and qualifiers" do
      visit edit_food_path(food)

      fill_in "Food name", with: "Purple Carrot"
      uncheck "qualifier_#{qualifier1.id}"
      check "qualifier_#{qualifier2.id}"

      click_button "Update Food"

      expect(page).to have_content("Food was successfully updated")
      expect(page).to have_content("Purple carrot") # Food names are normalized to lowercase with first letter capitalized
      expect(page).to have_content("Fresh")
      expect(page).not_to have_content("Organic")
    end

    it "adds a new qualifier during edit" do
      visit edit_food_path(food)

      # Fill in the new qualifier field
      fill_in "new_qualifier_name", with: "Local"

      click_button "Update Food"

      expect(page).to have_content("Food was successfully updated")
      expect(page).to have_content("Carrot")
      expect(page).to have_content("Organic") # Original qualifier still there
      expect(page).to have_content("Local") # New qualifier added
    end
    
    it "validates uniqueness of food signatures" do
      # First verify our test food exists with the expected qualifier
      expect(food.food_name).to eq("Carrot")
      expect(food.food_qualifiers).to include(qualifier1)
      
      # Try to create another food with the exact same name and qualifier
      # This should fail due to uniqueness validation
      second_food = Food.new(food_name: "Carrot")
      second_food.food_qualifiers << qualifier1
      
      # This should be invalid
      expect(second_food).not_to be_valid
      expect(second_food.errors[:unique_signature]).to include("A food with this name and the same qualifiers already exists")
    end
    
    it "enforces unique combinations of food names and qualifiers", js: true do
      # Try to create a new food with the same name but without qualifiers
      visit new_food_path
      
      # Enter the same name as our existing food
      fill_in "Food name", with: "Carrot"
      
      # Don't select any qualifiers
      
      # Submit the form
      click_button "Create Food"
      
      # Should see error about duplicate signature
      expect(page).to have_content("A food with this name and the same qualifiers already exists")
    end
  end

  describe "viewing a food" do
    let!(:food) { create(:food, :with_specific_qualifiers, qualifier_names: [ "Organic", "Local" ]) }

    it "displays food details with qualifiers" do
      visit food_path(food)

      expect(page).to have_content(food.food_name)
      expect(page).to have_content("Organic")
      expect(page).to have_content("Local")
      expect(page).to have_content("Unique Identifier")
      expect(page).to have_content(food.unique_signature)
    end
  end

  describe "listing foods" do
    let!(:food1) { create(:food, :with_specific_qualifiers, food_name: "Apple", qualifier_names: [ "Organic" ]) }
    let!(:food2) { create(:food, :with_specific_qualifiers, food_name: "Banana", qualifier_names: [ "Fresh", "Imported" ]) }

    it "displays all foods with their qualifiers" do
      visit foods_path

      expect(page).to have_content("Apple")
      expect(page).to have_content("Banana")
      expect(page).to have_content("Organic")
      expect(page).to have_content("Fresh")
      expect(page).to have_content("Imported")
    end
  end

  context "when deleting a food" do
    let!(:food) { create(:food, food_name: "Lettuce") }
    
    it "deletes the food and displays a success message", js: true do
      visit foods_path
      
      # Find the row containing the food name and click its delete button
      within("li", text: food.food_name) do
        click_button "Delete"
      end
      
      # Accept the confirmation dialog
      accept_confirm
      
      # Check for success message
      expect(page).to have_content("Food was successfully deleted")
      
      # Food should be completely removed
      expect(page).not_to have_content("Lettuce")
      
      # Food should be deleted from the database
      expect(Food.find_by(id: food.id)).to be_nil
    end
  end
end
