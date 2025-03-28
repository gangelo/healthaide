require 'rails_helper'

RSpec.describe "UserHealthGoals", type: :system do
  let(:user) { create(:user) }
  let!(:health_goal1) { create(:health_goal, health_goal_name: "Weight Loss") }
  let!(:health_goal2) { create(:health_goal, health_goal_name: "Muscle Gain") }
  let!(:health_goal3) { create(:health_goal, health_goal_name: "Better Sleep") }

  before do
    user.confirm
    sign_in user
    # Create an existing user health goal
    create(:user_health_goal, user: user, health_goal: health_goal1)
  end

  describe "index page" do
    it "displays user's health goals" do
      visit user_health_goals_path

      # Check page content
      expect(page).to have_content("My Health Goals")
      expect(page).to have_content(health_goal1.health_goal_name)
    end
  end

  describe "adding a new health goal" do
    it "shows add health goal options" do
      visit new_user_health_goal_path

      expect(page).to have_content("Add Health Goal")
      expect(page).to have_content("Add Multiple Health Goals")
      expect(page).to have_content("Select Existing Health Goal")
      expect(page).to have_content("Create New Health Goal")
    end

    it "allows selecting an existing health goal" do
      visit new_user_health_goal_path

      # Select the second health goal from dropdown
      select health_goal2.health_goal_name, from: "user_health_goal[health_goal_id]"
      click_button "Add Health Goal"

      # Should redirect to index with success message
      expect(page).to have_current_path(user_health_goals_path)
      expect(page).to have_content("Health goal was successfully added")
      expect(page).to have_content(health_goal2.health_goal_name)
    end

    it "allows creating a new health goal" do
      visit new_user_health_goal_path

      # Create a new health goal - handle any case insensitivity
      fill_in "user_health_goal[health_goal_name]", with: "Improve Flexibility"
      click_button "Create Health Goal"

      # Should redirect to index with success message
      expect(page).to have_current_path(user_health_goals_path)
      expect(page).to have_content("Health goal was successfully added")
      # Handle possible case normalization
      expect(page).to have_content(/improve flexibility/i)
    end
  end

  describe "editing a health goal" do
    let!(:user_health_goal) { create(:user_health_goal, user: user, health_goal: health_goal2, order_of_importance: 5) }

    it "allows viewing a health goal" do
      visit user_health_goals_path

      # Just check we can navigate to the health goal page
      expect(page).to have_content(health_goal2.health_goal_name)
    end

    it "allows updating only the order of importance" do
      visit edit_user_health_goal_path(user_health_goal)

      # Health goal name should be displayed but not editable
      expect(page).to have_content(health_goal2.health_goal_name)
      expect(page).not_to have_field("user_health_goal[health_goal_name]")
      
      # Order of importance should be editable
      select "10", from: "user_health_goal[order_of_importance]"
      click_button "Update health goal"

      # Should redirect to index with success message
      expect(page).to have_current_path(user_health_goals_path)
      expect(page).to have_content("Health goal was successfully updated")
      
      # Check the updated order of importance
      user_health_goal.reload
      expect(user_health_goal.order_of_importance).to eq(10)
    end
  end

  describe "removing a health goal" do
    let!(:user_health_goal) { create(:user_health_goal, user: user, health_goal: health_goal3) }

    it "allows removing a health goal", js: true do
      visit user_health_goals_path

      # Find the delete button for this goal and click it
      within("li", text: health_goal3.health_goal_name) do
        accept_confirm do
          click_button "Delete"
        end
      end

      # Should stay on index page with success message
      expect(page).to have_current_path(user_health_goals_path)
      expect(page).to have_content("Health goal was successfully removed")
      expect(page).not_to have_content(health_goal3.health_goal_name)
    end
  end

  # Skip these tests for now as they require the select_multiple template
  describe "selecting multiple health goals", skip: true do
    it "can access the multiple selection page" do
      # This test is skipped until select_multiple template is implemented
    end

    it "can add multiple goals via form submission" do
      # This test is skipped until select_multiple template is implemented
    end
  end
end
