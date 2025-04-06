# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Selecting multiple health conditions", type: :system do
  let(:user) { create(:user) }
  let!(:health_condition1) { create(:health_condition, health_condition_name: "Diabetes") }
  let!(:health_condition2) { create(:health_condition, health_condition_name: "Hypertension") }
  let!(:health_condition3) { create(:health_condition, health_condition_name: "Asthma") }
  let!(:health_condition4) { create(:health_condition, health_condition_name: "Arthritis") }

  before do
    user.confirm
    sign_in user
    # Add one health condition to the user
    create(:user_health_condition, user: user, health_condition: health_condition1)
  end

  scenario "User can open the multiple selection modal", js: true do
    visit new_user_health_condition_path

    click_link "Choose Multiple Health Conditions"

    expect(page).to have_content("Select Health Conditions")
    expect(page).to have_content(health_condition2.health_condition_name)
    expect(page).to have_content(health_condition3.health_condition_name)
    expect(page).to have_content(health_condition4.health_condition_name)
    expect(page).not_to have_content(health_condition1.health_condition_name) # Already added
  end

  scenario "User can search for health conditions in the modal", js: true do
    visit new_user_health_condition_path

    click_link "Choose Multiple Health Conditions"

    # Search for specific term
    fill_in "Search health conditions...", with: "arth"

    # Wait for results to update
    within("#health_conditions_list") do
      expect(page).to have_content(health_condition4.health_condition_name) # "Arthritis"
      expect(page).not_to have_content(health_condition2.health_condition_name) # "Hypertension"
      expect(page).not_to have_content(health_condition3.health_condition_name) # "Asthma"
    end
  end

  scenario "User can select multiple health conditions", js: true do
    visit new_user_health_condition_path

    click_link "Choose Multiple Health Conditions"

    # Select multiple conditions using checkboxes
    check "health_condition_ids_#{health_condition2.id}"
    check "health_condition_ids_#{health_condition4.id}"

    # Click add button
    click_button "Add Selected Health Conditions"

    expect(page).to have_current_path(new_user_health_condition_path)

    # Verify result
    expect(page).to have_content("2 health conditions successfully added")
  end

  scenario "User cannot submit without selecting any conditions", js: true do
    visit new_user_health_condition_path

    click_link "Choose Multiple Health Conditions"

    # Don't select any checkboxes

    # Add button should be disabled
    expect(page).to have_button("Add Selected Health Conditions", disabled: true)
  end

  scenario "User can use select all button", js: true do
    visit new_user_health_condition_path

    click_link "Choose Multiple Health Conditions"

    # Use select all button
    click_button "Select All"

    # All available checkboxes should be checked
    expect(page).to have_checked_field("health_condition_ids_#{health_condition2.id}")
    expect(page).to have_checked_field("health_condition_ids_#{health_condition3.id}")
    expect(page).to have_checked_field("health_condition_ids_#{health_condition4.id}")

    # Add button should be enabled
    expect(page).to have_button("Add Selected Health Conditions", disabled: false)
  end

  scenario "User can use select none button", js: true do
    visit new_user_health_condition_path

    click_link "Choose Multiple Health Conditions"

    # First select all
    click_button "Select All"

    # Then deselect all
    click_button "Select None"

    # No checkboxes should be checked
    expect(page).to have_unchecked_field("health_condition_ids_#{health_condition2.id}")
    expect(page).to have_unchecked_field("health_condition_ids_#{health_condition3.id}")
    expect(page).to have_unchecked_field("health_condition_ids_#{health_condition4.id}")

    # Add button should be disabled again
    expect(page).to have_button("Add Selected Health Conditions", disabled: true)
  end

  scenario "User can cancel the modal", js: true do
    visit new_user_health_condition_path

    click_link "Choose Multiple Health Conditions"

    # Check modal is open
    expect(page).to have_content("Select Health Conditions")

    # Click cancel
    click_link "Cancel"

    # The modal should close
    expect(page).not_to have_content("Select Health Conditions")

    expect(page).to have_current_path(user_health_conditions_path)
  end
end
