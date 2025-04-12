# frozen_string_literal: true

RSpec.describe "Health Conditions Management", type: :system do
  let(:user) { create(:user, :admin) }

  before do
    user.confirm
    sign_in user
  end

  describe "creating a new health condition" do
    it "creates a new health condition" do
      visit new_health_condition_path

      fill_in "Health condition name", with: "Diabetes"
      click_button "Create Health condition"

      expect(page).to have_content("Health condition was successfully created")
      expect(page).to have_content("Diabetes")
    end

    it "validates health condition uniqueness" do
      create(:health_condition, health_condition_name: "Hypertension")

      visit new_health_condition_path

      fill_in "Health condition name", with: "hypertension" # Testing case-insensitivity
      click_button "Create Health condition"

      expect(page).to have_content("Health condition name has already been taken")
    end
  end

  describe "editing a health condition" do
    let!(:health_condition) { create(:health_condition, health_condition_name: "Asthma") }

    it "updates health condition name" do
      visit edit_health_condition_path(health_condition)

      fill_in "Health condition name", with: "Severe Asthma"
      click_button "Update Health condition"

      expect(page).to have_content("Health condition was successfully updated")
      expect(page).to have_content("Severe asthma") # Normalized name
    end
  end

  describe "viewing a health condition" do
    let!(:health_condition) { create(:health_condition, health_condition_name: "Diabetes") }

    it "displays health condition details" do
      visit health_condition_path(health_condition)

      expect(page).to have_content(health_condition.health_condition_name)
    end
  end

  describe "listing health conditions" do
    let!(:health_condition1) { create(:health_condition, health_condition_name: "Diabetes") }
    let!(:health_condition2) { create(:health_condition, health_condition_name: "Hypertension") }

    it "displays all health conditions" do
      visit health_conditions_path

      expect(page).to have_content(health_condition1.health_condition_name)
      expect(page).to have_content(health_condition2.health_condition_name)
    end
  end

  context "when deleting a health condition" do
    let!(:health_condition) { create(:health_condition, health_condition_name: "Arthritis") }

    it "deletes the health condition and displays a success message", js: true do
      visit health_conditions_path

      # Find the row containing the health condition name and click its delete button
      within("li", text: health_condition.health_condition_name) do
        click_button "Delete"
      end

      # Accept the confirmation dialog
      accept_confirm

      # Check for success message
      expect(page).to have_content("Health condition was successfully deleted")

      # Health condition should be completely removed
      expect(page).not_to have_content("Arthritis")

      # Health condition should be deleted from the database
      expect(HealthCondition.find_by(id: health_condition.id)).to be_nil
    end
  end
end
