# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Adding new health goals", type: :system do
  let(:user) { create(:user) }
  let!(:existing_health_goal) { create(:health_goal, health_goal_name: "Weight Loss") }

  before do
    user.confirm
    sign_in user
  end

  scenario "User can navigate to the new health goal form" do
    visit user_health_goals_path

    # NOTE: We need to match: :first because there are no goals in the list yet
    # and the "Add" button appears twice in the UI.
    click_link "Add Health Goal", match: :first

    expect(page).to have_current_path(new_user_health_goal_path)

    # Check that the new UI is displayed with dual panel selection
    expect(page).to have_content("Available Health Goals")
    expect(page).to have_content("Selected Health Goals")
    expect(page).to have_button("Add Selected Goals", disabled: true)
  end

  scenario "User can create a new health goal using search", js: true do
    visit new_user_health_goal_path

    # Search for a goal that doesn't exist
    fill_in "Search health goals...", with: "Improve Flexibility"

    # Wait for the "Add New Health Goal" form to appear
    expect(page).to have_content("This health goal doesn't exist yet")

    # Create new goal through the "Add New" form
    within("[data-health-goal-selection-target='newGoalForm']") do
      # The input should be pre-filled with the search term
      expect(find("[data-health-goal-selection-target='newGoalInput']").value).to eq("Improve Flexibility")
      click_button "Add"
    end

    # Submit the form to add the new goal
    click_button "Add Selected Goals"

    # Verify the result
    expect(page).to have_current_path(user_health_goals_path)
    expect(page).to have_content("successfully added")
    expect(page).to have_content(/improve flexibility/i)
  end

  scenario "User cannot create a health goal with an empty name", js: true do
    visit new_user_health_goal_path

    # Try to search with empty string, which shouldn't show the "Add New" form
    fill_in "Search health goals...", with: ""

    # The "Add New" form should not be visible
    expect(page).not_to have_css("[data-health-goal-selection-target='newGoalForm']:not(.hidden)")
  end

  scenario "User cannot create a duplicate health goal", js: true do
    visit new_user_health_goal_path

    # Search for an existing goal
    fill_in "Search health goals...", with: existing_health_goal.health_goal_name

    # The goal should appear in the available list and not in the "Add New" form
    expect(page).to have_content(existing_health_goal.health_goal_name)
    expect(page).not_to have_css("[data-health-goal-selection-target='newGoalForm']:not(.hidden)")
  end
end
