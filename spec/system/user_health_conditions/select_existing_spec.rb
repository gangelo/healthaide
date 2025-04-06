# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Selecting existing health conditions", type: :system do
  let(:user) { create(:user) }
  let!(:health_condition1) { create(:health_condition, health_condition_name: "Diabetes") }
  let!(:health_condition2) { create(:health_condition, health_condition_name: "Hypertension") }
  let!(:health_condition3) { create(:health_condition, health_condition_name: "Asthma") }

  before do
    user.confirm
    sign_in user
    # Add one health condition to the user
    create(:user_health_condition, user: user, health_condition: health_condition1)
  end

  scenario "User can see available health conditions in dropdown" do
    visit new_user_health_condition_path

    # Check dropdown options
    within("#select-existing-form") do
      dropdown_options = page.all('select#user_health_condition_health_condition_id option').map(&:text)
      expect(dropdown_options).to include(health_condition2.health_condition_name)
      expect(dropdown_options).to include(health_condition3.health_condition_name)
      expect(dropdown_options).not_to include(health_condition1.health_condition_name) # Already added
    end
  end

  scenario "User can select an existing health condition" do
    visit new_user_health_condition_path

    # Select from dropdown
    within("#select-existing-form") do
      select health_condition2.health_condition_name, from: "user_health_condition[health_condition_id]"
      click_button "Add Selected Health Condition"
    end

    expect(page).to have_current_path(user_health_conditions_path)

    # Verify the result
    expect(page).to have_content("Health condition was successfully added")
    expect(page).to have_content(health_condition2.health_condition_name)
  end

  scenario "User must select a health condition" do
    visit new_user_health_condition_path

    # Try to submit without selecting a condition
    within("#select-existing-form") do
      # Don't select anything from dropdown
      click_button "Add Selected Health Condition"
    end

    # Should see validation error
    expect(page).to have_content("Health condition can't be blank")
  end

  scenario "User cannot add a health condition they already have" do
    # First add health_condition2
    create(:user_health_condition, user: user, health_condition: health_condition2)

    visit new_user_health_condition_path

    # Check dropdown options
    within("#select-existing-form") do
      dropdown_options = page.all('select#user_health_condition_health_condition_id option').map(&:text)
      expect(dropdown_options).not_to include(health_condition1.health_condition_name) # Already added
      expect(dropdown_options).not_to include(health_condition2.health_condition_name) # Already added
      expect(dropdown_options).to include(health_condition3.health_condition_name) # Available
    end
  end
end
