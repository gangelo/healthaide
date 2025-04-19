# frozen_string_literal: true

RSpec.describe "Food Qualifiers Management", type: :system do
  let(:user) { create(:user, :admin) }

  before do
    user.confirm
    sign_in user
  end

  describe "creating a new food qualifier" do
    it "creates a new food qualifier" do
      visit new_food_qualifier_path

      fill_in "Qualifier name", with: "Organic"
      find('input[type="submit"][value*="Create"]').click

      expect(page).to have_content("Food qualifier was successfully created")
      expect(page).to have_content("Organic")
    end

    it "validates qualifier uniqueness" do
      create(:food_qualifier, qualifier_name: "Organic")

      visit new_food_qualifier_path

      fill_in "Qualifier name", with: "organic" # Testing case-insensitivity
      find('input[type="submit"][value*="Create"]').click

      expect(page).to have_content("Qualifier name has already been taken")
    end
  end

  describe "editing a food qualifier" do
    let!(:qualifier) { create(:food_qualifier, qualifier_name: "Fresh") }
    let!(:existing_qualifier) { create(:food_qualifier, qualifier_name: "Organic") }

    it "updates food qualifier name" do
      visit edit_food_qualifier_path(qualifier)

      fill_in "Qualifier name", with: "Extra Fresh"
      find('input[type="submit"][value*="Update"]').click

      expect(page).to have_content("Food qualifier was successfully updated")
      expect(page).to have_content("Extra fresh") # Normalized name
    end

    it "prevents renaming to an existing qualifier name" do
      visit edit_food_qualifier_path(qualifier)

      fill_in "Qualifier name", with: "Organic" # Already exists
      find('input[type="submit"][value*="Update"]').click

      expect(page).to have_content("Qualifier name has already been taken")
      expect(qualifier.reload.qualifier_name).to eq("Fresh") # Name didn't change
    end
  end

  describe "viewing a food qualifier" do
    let!(:qualifier) { create(:food_qualifier, qualifier_name: "Organic") }
    let!(:food) { create(:food, food_name: "Apple") }

    before do
      food.food_qualifiers << qualifier
    end

    it "displays food qualifier details" do
      visit food_qualifier_path(qualifier)

      expect(page).to have_content(qualifier.qualifier_name)
      # The view doesn't currently show associated foods
    end
  end

  describe "listing food qualifiers" do
    let!(:qualifier1) { create(:food_qualifier, qualifier_name: "Organic") }
    let!(:qualifier2) { create(:food_qualifier, qualifier_name: "Fresh") }

    it "displays all food qualifiers" do
      visit food_qualifiers_path

      expect(page).to have_content(qualifier1.qualifier_name)
      expect(page).to have_content(qualifier2.qualifier_name)
    end
  end

  context "when deleting a food qualifier" do
    context "when the qualifier is not used by any food" do
      let!(:qualifier) { create(:food_qualifier, qualifier_name: "Unused") }

      it "deletes the qualifier and displays a success message", js: true do
        visit food_qualifiers_path

        # Find the row containing the qualifier name and click its delete button
        within("li", text: qualifier.qualifier_name) do
          click_button "Delete"
        end

        # Accept the confirmation dialog
        accept_confirm

        # Check for success message
        expect(page).to have_content("Food qualifier was successfully deleted")

        # Verify qualifier is no longer visible in the list
        expect(page).not_to have_content("Unused")

        # Verify qualifier is actually deleted from the database (not soft deleted)
        expect(FoodQualifier.find_by(id: qualifier.id)).to be_nil
      end
    end

    context "when the qualifier is used by a food" do
      let!(:qualifier) { create(:food_qualifier, qualifier_name: "Used") }
      let!(:food) { create(:food, food_name: "Apple") }

      before do
        food.food_qualifiers << qualifier
      end

      it "prevents deletion and displays an error message", js: true do
        visit food_qualifiers_path

        # Find the row containing the qualifier name and click its delete button
        within("li", text: qualifier.qualifier_name) do
          click_button "Delete"
        end

        # Accept the confirmation dialog
        accept_confirm

        # Check for error message
        expect(page).to have_content("Food qualifier is being used and cannot be deleted")

        # Verify qualifier is still visible in the list
        expect(page).to have_content("Used")

        # Verify qualifier still exists in the database
        expect(FoodQualifier.find_by(id: qualifier.id)).to be_present
      end
    end
  end
end
