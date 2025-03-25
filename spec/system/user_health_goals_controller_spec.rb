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
    create(:user_health_goal, user: user, health_goal: health_goal1, order_of_importance: 1)
  end

  describe "index page" do
    it "displays user's health goals" do
      visit user_health_goals_path
      
      # Check page content
      expect(page).to have_content("My Health Goals")
      expect(page).to have_content(health_goal1.health_goal_name)
      expect(page).to have_content("1") # order of importance
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
      
      # Create a new health goal
      fill_in "user_health_goal[health_goal_name]", with: "Improve Flexibility"
      click_button "Create Health Goal"
      
      # Should redirect to index with success message
      expect(page).to have_current_path(user_health_goals_path)
      expect(page).to have_content("Health goal was successfully added")
      expect(page).to have_content("Improve Flexibility")
    end
  end
  
  describe "editing a health goal" do
    let!(:user_health_goal) { create(:user_health_goal, user: user, health_goal: health_goal2, order_of_importance: 5) }
    
    it "allows updating the order of importance" do
      visit edit_user_health_goal_path(user_health_goal)
      
      # Change order of importance
      fill_in "user_health_goal[order_of_importance]", with: 8
      click_button "Update Health Goal"
      
      # Should redirect to index with updated order
      expect(page).to have_current_path(user_health_goals_path)
      expect(page).to have_content("Health goal was successfully updated")
      
      # Verify the new order of importance is displayed
      expect(page).to have_content("8")
    end
  end
  
  describe "removing a health goal" do
    let!(:user_health_goal) { create(:user_health_goal, user: user, health_goal: health_goal3, order_of_importance: 3) }
    
    it "allows removing a health goal" do
      visit user_health_goals_path
      
      # Find the delete button for this goal and click it
      within("tr", text: health_goal3.health_goal_name) do
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
  
  # Tests that would require JavaScript (disabled for now)
  describe "selecting multiple health goals" do
    it "can access the multiple selection page" do
      visit select_multiple_user_health_goals_path
      
      # Check that the page loads and shows available goals
      expect(page).to have_content("Select Health Goals")
      expect(page).to have_content(health_goal2.health_goal_name)
      expect(page).to have_content(health_goal3.health_goal_name)
    end
    
    it "can add multiple goals via form submission" do
      # Directly submit the form to add multiple goals
      page.driver.post add_multiple_user_health_goals_path, { 
        health_goal_ids: [health_goal2.id, health_goal3.id] 
      }
      
      # Visit the index page to verify goals were added
      visit user_health_goals_path
      
      # Check that both goals are now in the list
      expect(page).to have_content(health_goal2.health_goal_name)
      expect(page).to have_content(health_goal3.health_goal_name)
    end
  end
end