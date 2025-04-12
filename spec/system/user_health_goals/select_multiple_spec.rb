# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Selecting multiple health goals", type: :system do
  let(:user) { create(:user) }
  let!(:health_goal1) { create(:health_goal, health_goal_name: "Weight Loss") }
  let!(:health_goal2) { create(:health_goal, health_goal_name: "Muscle Gain") }
  let!(:health_goal3) { create(:health_goal, health_goal_name: "Better Sleep") }
  let!(:health_goal4) { create(:health_goal, health_goal_name: "Improved Flexibility") }

  before do
    user.confirm
    sign_in user
    # Add one health goal to the user
    create(:user_health_goal, user: user, health_goal: health_goal1)
  end

  scenario "User can see available health goals", js: true do
    visit new_user_health_goal_path

    # The new interface is always showing the selection UI directly on the page
    expect(page).to have_content("Available Health Goals")
    expect(page).to have_content("Selected Health Goals")

    # Check goals are displayed
    within("[data-health-goal-selection-target='availableList']") do
      expect(page).to have_content(health_goal2.health_goal_name)
      expect(page).to have_content(health_goal3.health_goal_name)
      expect(page).to have_content(health_goal4.health_goal_name)
      expect(page).not_to have_content(health_goal1.health_goal_name) # Already added
    end
  end

  scenario "User can search for health goals", js: true do
    visit new_user_health_goal_path

    # Search for specific term
    fill_in "Search health goals...", with: "flex"

    # Wait for results to update
    within("[data-health-goal-selection-target='availableList']") do
      expect(page).to have_content(health_goal4.health_goal_name) # "Improved Flexibility"
      expect(page).not_to have_content(health_goal2.health_goal_name) # "Muscle Gain"
      expect(page).not_to have_content(health_goal3.health_goal_name) # "Better Sleep"
    end
  end

  scenario "User can select multiple health goals", js: true do
    visit new_user_health_goal_path

    # Select multiple goals by clicking them
    find("[data-goal-id='#{health_goal2.id}']").click
    find("[data-goal-id='#{health_goal4.id}']").click

    # Verify they moved to selected list
    within("[data-health-goal-selection-target='selectedList']") do
      expect(page).to have_content(health_goal2.health_goal_name)
      expect(page).to have_content(health_goal4.health_goal_name)
    end

    # Click add button
    click_button "Add Selected Goals"

    # Verify result
    expect(page).to have_current_path(user_health_goals_path)
    expect(page).to have_content("successfully added")
    expect(page).to have_content(health_goal2.health_goal_name)
    expect(page).to have_content(health_goal4.health_goal_name)
  end

  scenario "User cannot submit without selecting any goals", js: true do
    visit new_user_health_goal_path

    # Don't select any goals
    # Add button should be disabled
    expect(page).to have_button("Add Selected Goals", disabled: true)
  end

  scenario "User can use the Clear All button", js: true do
    visit new_user_health_goal_path

    # Select a couple goals first
    find("[data-goal-id='#{health_goal2.id}']").click
    find("[data-goal-id='#{health_goal4.id}']").click

    # Verify selection
    within("[data-health-goal-selection-target='selectedList']") do
      expect(page).to have_content(health_goal2.health_goal_name)
      expect(page).to have_content(health_goal4.health_goal_name)
    end

    # Now clear all
    click_button "Clear All"

    # No goals should be in the selected list
    within("[data-health-goal-selection-target='selectedList']") do
      expect(page).not_to have_content(health_goal2.health_goal_name)
      expect(page).not_to have_content(health_goal4.health_goal_name)
    end

    # Goals should be back in the available list
    within("[data-health-goal-selection-target='availableList']") do
      expect(page).to have_content(health_goal2.health_goal_name)
      expect(page).to have_content(health_goal4.health_goal_name)
    end

    # Add button should be disabled again
    expect(page).to have_button("Add Selected Goals", disabled: true)
  end

  scenario "User can navigate back to health goals list", js: true do
    visit new_user_health_goal_path

    # Click the back link
    click_link "Back to My Health Goals"

    # Should return to health goals list
    expect(page).to have_current_path(user_health_goals_path)
  end
end
