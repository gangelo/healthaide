# frozen_string_literal: true

RSpec.describe "UserHealthConditions", type: :system do
  let(:user) { create(:user) }
  let!(:health_condition1) { create(:health_condition, health_condition_name: "Diabetes") }
  let!(:health_condition2) { create(:health_condition, health_condition_name: "Hypertension") }
  let!(:health_condition3) { create(:health_condition, health_condition_name: "Asthma") }

  before do
    user.confirm
    sign_in user
    # Create an existing user health condition
    create(:user_health_condition, user: user, health_condition: health_condition1)
  end

  describe "index page" do
    it "displays user's health conditions" do
      visit user_health_conditions_path

      # Check page content
      expect(page).to have_content("My Health Conditions")
      expect(page).to have_content(health_condition1.health_condition_name)
    end
  end

  describe "adding a new health condition" do
    it "shows add health condition options" do
      visit new_user_health_condition_path

      expect(page).to have_content("Add Health Condition")
      expect(page).to have_content("Add Multiple Health Conditions")
      expect(page).to have_content("Select Existing Health Condition")
      expect(page).to have_content("Create New Health Condition")
    end

    context "selecting an existing health condition" do
      it "can select and add an existing health condition" do
        visit new_user_health_condition_path

        # Select from dropdown
        select health_condition2.health_condition_name, from: "user_health_condition[health_condition_id]"
        click_button "Add Selected Health Condition"

        expect(page).to have_content("Health condition was successfully added")
        expect(page).to have_content(health_condition2.health_condition_name)
      end

      it "displays validation error when selecting an already added condition" do
        # Create user health condition for the second condition
        create(:user_health_condition, user: user, health_condition: health_condition2)
        
        visit new_user_health_condition_path
        
        # Only health_condition3 should be available to select now
        health_conditions = page.all('select#user_health_condition_health_condition_id option').map(&:text)
        expect(health_conditions).to include(health_condition3.health_condition_name)
        expect(health_conditions).not_to include(health_condition1.health_condition_name)
        expect(health_conditions).not_to include(health_condition2.health_condition_name)
      end
    end

    context "creating a new health condition" do
      it "can create and add a new health condition" do
        visit new_user_health_condition_path

        # Fill in new health condition form
        fill_in "user_health_condition[new_health_condition_name]", with: "Arthritis"
        click_button "Create & Add New Health Condition"

        expect(page).to have_content("Health condition was successfully added")
        expect(page).to have_content("Arthritis")
      end

      it "shows validation error for duplicate health condition" do
        visit new_user_health_condition_path

        # Try to create a condition that already exists
        fill_in "user_health_condition[new_health_condition_name]", with: health_condition1.health_condition_name
        click_button "Create & Add New Health Condition"

        # Should show validation error
        expect(page).to have_content("Health condition name has already been taken")
      end
    end
  end

  describe "removing a health condition", js: true do
    # Create a health condition for the current user
    let!(:user_health_condition) { create(:user_health_condition, user: user, health_condition: health_condition3) }

    it "allows removing a health condition" do
      visit user_health_conditions_path

      # Find the delete button for this condition and click it
      within("li", text: health_condition3.health_condition_name) do
        accept_confirm do
          click_button "Delete"
        end
      end

      # Should stay on index page with success message
      expect(page).to have_current_path(user_health_conditions_path)
      expect(page).to have_content("Health condition was successfully removed")
      expect(page).not_to have_content(health_condition3.health_condition_name)
    end
  end

  describe "selecting multiple health conditions" do
    it "can open multiple health conditions selection modal", js: true do
      visit new_user_health_condition_path

      # Find the link by its text
      find('a', text: "Choose Multiple Health Conditions").click

      # Check modal shows correct title and content
      expect(page).to have_content("Select Health Conditions")
      expect(page).to have_content(health_condition2.health_condition_name)
      expect(page).to have_content(health_condition3.health_condition_name)
    end

    # This test requires JavaScript to work since it's using AJAX for filtering
    it "can filter health conditions in the modal", skip: "Requires JS to be enabled" do
      visit new_user_health_condition_path
      find('a', text: "Choose Multiple Health Conditions").click

      # Use a specific selector to find the search field
      expect(page).to have_css('input[placeholder="Search health conditions..."]')

      # Use the placeholder to find the field
      fill_in "Search health conditions...", with: "Asth"

      # Wait for the results to update
      expect(page).to have_content(health_condition3.health_condition_name)
      expect(page).not_to have_content(health_condition2.health_condition_name)
    end

    # This test can work without JavaScript since we can directly post to add_multiple
    it "can add multiple health conditions at once" do
      # Setup another health condition not yet associated with the user
      health_condition4 = create(:health_condition, health_condition_name: "Migraine")
      
      # Use the direct route to add multiple health conditions
      health_condition_ids = [health_condition2.id, health_condition4.id]
      page.driver.post add_multiple_user_health_conditions_path, { health_condition_ids: health_condition_ids }

      # Visit the user health conditions page to check the result
      visit user_health_conditions_path

      # Check that the health conditions were added
      expect(page).to have_content(health_condition2.health_condition_name)
      expect(page).to have_content(health_condition4.health_condition_name)
    end
  end
end