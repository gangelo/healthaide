# frozen_string_literal: true

RSpec.describe "Health Goals Management", type: :system do
  let(:user) { create(:user, :admin) }

  before do
    user.confirm
    sign_in user
  end

  describe "creating a new health goal" do
    it "creates a new health goal" do
      visit new_health_goal_path

      fill_in "Health goal name", with: "Weight Loss"
      click_button "Create Health goal"

      expect(page).to have_content("Health goal was successfully created")
      expect(page).to have_content("Weight loss") # Normalized name
    end

    it "validates health goal uniqueness" do
      create(:health_goal, health_goal_name: "Muscle Building")

      visit new_health_goal_path

      fill_in "Health goal name", with: "muscle building" # Testing case-insensitivity
      click_button "Create Health goal"

      expect(page).to have_content("Health goal name has already been taken")
    end
  end

  describe "editing a health goal" do
    let!(:health_goal) { create(:health_goal, health_goal_name: "Better Sleep") }

    it "updates health goal name" do
      visit edit_health_goal_path(health_goal)

      fill_in "Health goal name", with: "Improved Sleep Quality"
      click_button "Update Health goal"

      expect(page).to have_content("Health goal was successfully updated")
      expect(page).to have_content("Improved sleep quality") # Normalized name
    end
  end

  describe "viewing a health goal" do
    let!(:health_goal) { create(:health_goal, health_goal_name: "Weight Loss") }

    it "displays health goal details" do
      visit health_goal_path(health_goal)

      expect(page).to have_content(health_goal.health_goal_name)
    end
  end

  describe "listing health goals" do
    let!(:health_goal1) { create(:health_goal, health_goal_name: "Weight Loss") }
    let!(:health_goal2) { create(:health_goal, health_goal_name: "Muscle Building") }

    it "displays all health goals" do
      visit health_goals_path

      expect(page).to have_content(health_goal1.health_goal_name)
      expect(page).to have_content(health_goal2.health_goal_name)
    end
  end

  context "when deleting a health goal" do
    let!(:health_goal) { create(:health_goal, health_goal_name: "Flexibility") }
    
    it "deletes the health goal and displays a success message", js: true do
      visit health_goals_path
      
      # Find the row containing the health goal name and click its delete button
      within("li", text: health_goal.health_goal_name) do
        click_button "Delete"
      end
      
      # Accept the confirmation dialog
      accept_confirm
      
      # Check for success message
      expect(page).to have_content("Health goal was successfully deleted")
      
      # Verify health goal is no longer visible in the list
      expect(page).not_to have_content("Flexibility")
      
      # Verify health goal is deleted from the database
      # Note: Health goals appear to use regular deletion, not soft deletion based on the controller
      expect(HealthGoal.find_by(id: health_goal.id)).to be_nil
    end
  end
end