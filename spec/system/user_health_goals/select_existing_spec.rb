# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Selecting existing health goals", type: :system do
  let(:user) { create(:user) }
  let!(:health_goal1) { create(:health_goal, health_goal_name: "Weight Loss") }
  let!(:health_goal2) { create(:health_goal, health_goal_name: "Muscle Gain") }
  let!(:health_goal3) { create(:health_goal, health_goal_name: "Better Sleep") }

  before do
    user.confirm
    sign_in user
    # Add one health goal to the user
    create(:user_health_goal, user: user, health_goal: health_goal1)
  end

  scenario "User can see available health goals", js: true do
    visit new_user_health_goal_path

    # Check available goals
    within("[data-health-goal-selection-target='availableList']") do
      expect(page).to have_content(health_goal2.health_goal_name)
      expect(page).to have_content(health_goal3.health_goal_name)
      expect(page).not_to have_content(health_goal1.health_goal_name) # Already added
    end
  end

  scenario "User can select an existing health goal", js: true do
    visit new_user_health_goal_path

    # Click on a goal to select it
    find("[data-goal-id='#{health_goal2.id}']").click
    
    # Verify it moved to selected list
    within("[data-health-goal-selection-target='selectedList']") do
      expect(page).to have_content(health_goal2.health_goal_name)
    end
    
    # Submit the form
    click_button "Add Selected Goals"

    # Verify the result
    expect(page).to have_current_path(user_health_goals_path)
    expect(page).to have_content("successfully added")
    expect(page).to have_content(health_goal2.health_goal_name)
  end

  scenario "User cannot submit without selecting a goal", js: true do
    visit new_user_health_goal_path

    # Don't select any goals
    # Add button should be disabled
    expect(page).to have_button("Add Selected Goals", disabled: true)
  end

  scenario "User cannot add a health goal they already have", js: true do
    # First add health_goal2
    create(:user_health_goal, user: user, health_goal: health_goal2)

    visit new_user_health_goal_path

    # Check available goals
    within("[data-health-goal-selection-target='availableList']") do
      expect(page).not_to have_content(health_goal1.health_goal_name) # Already added
      expect(page).not_to have_content(health_goal2.health_goal_name) # Already added
      expect(page).to have_content(health_goal3.health_goal_name) # Available
    end
  end
end
