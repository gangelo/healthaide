# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Managing health goals", type: :system do
  let(:user) { create(:user) }
  let!(:health_goal1) { create(:health_goal, health_goal_name: "Weight Loss") }
  let!(:health_goal2) { create(:health_goal, health_goal_name: "Muscle Gain") }

  before do
    user.confirm
    sign_in user
    # Create user health goals
    create(:user_health_goal, user: user, health_goal: health_goal1)
    create(:user_health_goal, user: user, health_goal: health_goal2, order_of_importance: 5)
  end

  scenario "User can view their health goals" do
    visit user_health_goals_path

    expect(page).to have_content("My Health Goals")
    expect(page).to have_content(health_goal1.health_goal_name)
    expect(page).to have_content(health_goal2.health_goal_name)
  end

  scenario "User can edit a health goal's importance" do
    visit user_health_goals_path

    # Find and click edit button for health_goal2
    within("li", text: health_goal2.health_goal_name) do
      click_link "Edit"
    end

    # Check we're on the edit page
    expect(page).to have_content("Editing health goal")
    expect(page).to have_content(health_goal2.health_goal_name)

    # Update importance
    select "10", from: "user_health_goal[order_of_importance]"
    click_button "Update health goal"

    # Verify the update
    expect(page).to have_current_path(user_health_goals_path)
    expect(page).to have_content("Health goal was successfully updated")
  end

  scenario "User can delete a health goal", js: true do
    visit user_health_goals_path

    # Find and click delete button for health_goal2
    within("li", text: health_goal2.health_goal_name) do
      accept_confirm do
        click_button "Delete"
      end
    end

    # Verify the deletion
    expect(page).to have_current_path(user_health_goals_path)
    expect(page).to have_content("Health goal was successfully removed")
    expect(page).not_to have_content(health_goal2.health_goal_name)
    expect(page).to have_content(health_goal1.health_goal_name) # Other goal still there
  end

  scenario "User can navigate back to list from edit page" do
    # First navigate to edit page
    visit edit_user_health_goal_path(UserHealthGoal.find_by(user: user, health_goal: health_goal2))

    # Click back/cancel button
    click_link "Back to health goals"

    # Verify we're back on the list
    expect(page).to have_current_path(user_health_goals_path)
  end

  scenario "User sees empty state when no goals are present" do
    # Remove all goals
    UserHealthGoal.destroy_all

    visit user_health_goals_path

    expect(page).to have_content("No health goals added yet")
    expect(page).to have_link("Add Health Goal")
  end
end
