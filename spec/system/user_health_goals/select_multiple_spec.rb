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

  scenario "User can open the multiple selection modal", js: true do
    visit new_user_health_goal_path

    click_link "Select Multiple Health Goals"

    within("turbo-frame#modal") do
      expect(page).to have_content("Select Health Goals")
    end

    within("turbo-frame#health_goals_list") do
      expect(page).to have_content(health_goal2.health_goal_name)
      expect(page).to have_content(health_goal3.health_goal_name)
      expect(page).to have_content(health_goal4.health_goal_name)
      expect(page).not_to have_content(health_goal1.health_goal_name) # Already added
    end
  end

  scenario "User can search for health goals in the modal", js: true do
    visit new_user_health_goal_path

    click_link "Select Multiple Health Goals"

    # Search for specific term
    fill_in "Search health goals...", with: "flex"

    # Wait for results to update
    within("turbo-frame#health_goals_list") do
      expect(page).to have_text(health_goal4.health_goal_name) # "Improved Flexibility"
      expect(page).to_not have_text(health_goal2.health_goal_name) # "Muscle Gain"
      expect(page).to_not have_text(health_goal3.health_goal_name) # "Better Sleep"
    end
  end

  scenario "User can select multiple health goals", js: true do
    visit new_user_health_goal_path

    click_link "Select Multiple Health Goals"

    # Select multiple goals using checkboxes
    check "health_goal_ids_#{health_goal2.id}"
    check "health_goal_ids_#{health_goal4.id}"

    # Click add button
    click_button "Add Selected Health Goals"

    # Verify result
    expect(page).to have_current_path(new_user_health_goal_path)
    expect(page).to have_content("2 health goals successfully added")

    visit user_health_goals_path
    expect(page).to have_content(health_goal2.health_goal_name)
    expect(page).to have_content(health_goal4.health_goal_name)
  end

  scenario "User cannot submit without selecting any goals", js: true do
    visit new_user_health_goal_path

    click_link "Select Multiple Health Goals"

    # Don't select any checkboxes

    # Add button should be disabled
    expect(page).to have_button("Add Selected Health Goals", disabled: true)
  end

  scenario "User can use select all button", js: true do
    visit new_user_health_goal_path

    click_link "Select Multiple Health Goals"

    # Use select all button
    click_button "Select All"

    # All available checkboxes should be checked
    expect(page).to have_checked_field("health_goal_ids_#{health_goal2.id}")
    expect(page).to have_checked_field("health_goal_ids_#{health_goal3.id}")
    expect(page).to have_checked_field("health_goal_ids_#{health_goal4.id}")

    # Add button should be enabled
    expect(page).to have_button("Add Selected Health Goals", disabled: false)
  end

  scenario "User can use select none button", js: true do
    visit new_user_health_goal_path

    click_link "Select Multiple Health Goals"

    # First select all
    click_button "Select All"

    # Then deselect all
    click_button "Select None"

    # No checkboxes should be checked
    expect(page).to have_unchecked_field("health_goal_ids_#{health_goal2.id}")
    expect(page).to have_unchecked_field("health_goal_ids_#{health_goal3.id}")
    expect(page).to have_unchecked_field("health_goal_ids_#{health_goal4.id}")

    # Add button should be disabled again
    expect(page).to have_button("Add Selected Health Goals", disabled: true)
  end

  scenario "User can cancel the modal", js: true do
    visit new_user_health_goal_path

    click_link "Select Multiple Health Goals"

    # Check modal is open
    expect(page).to have_content("Select Health Goals")

    # Click cancel
    click_link "Cancel"

    # Modal should be closed
    expect(page).not_to have_content("Select Health Goals")
    expect(page).to have_current_path(new_user_health_goal_path)
  end
end
