# frozen_string_literal: true

RSpec.describe "Foods Management", type: :system do
  let(:user) { create(:user) }
  
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
      
      visit new_food_path
      
      # Try to create the same food with the same qualifier
      fill_in "Food name", with: "Apple"
      check "qualifier_#{qualifier1.id}"
      
      click_button "Create Food"
      
      # Should see an error
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
  end

  describe "viewing a food" do
    let!(:food) { create(:food, :with_specific_qualifiers, qualifier_names: ["Organic", "Local"]) }
    
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
    let!(:food1) { create(:food, :with_specific_qualifiers, food_name: "Apple", qualifier_names: ["Organic"]) }
    let!(:food2) { create(:food, :with_specific_qualifiers, food_name: "Banana", qualifier_names: ["Fresh", "Imported"]) }
    
    it "displays all foods with their qualifiers" do
      visit foods_path
      
      expect(page).to have_content("Apple")
      expect(page).to have_content("Banana")
      expect(page).to have_content("Organic")
      expect(page).to have_content("Fresh")
      expect(page).to have_content("Imported")
    end
  end
end