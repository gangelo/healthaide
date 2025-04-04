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

  scenario "User can see available health goals in dropdown" do
    visit new_user_health_goal_path

    # Check dropdown options
    within("#select-existing-goal") do
      dropdown_options = page.all('select#user_health_goal_health_goal_id option').map(&:text)
      expect(dropdown_options).to include(health_goal2.health_goal_name)
      expect(dropdown_options).to include(health_goal3.health_goal_name)
      expect(dropdown_options).not_to include(health_goal1.health_goal_name) # Already added
    end
  end

  scenario "User can select an existing health goal" do
    visit new_user_health_goal_path

    # Select from dropdown
    within("#select-existing-goal") do
      select health_goal2.health_goal_name, from: "user_health_goal[health_goal_id]"
      click_button "Add Health Goal"
    end

    # Verify the result
    expect(page).to have_current_path(user_health_goals_path)
    expect(page).to have_content("Health goal was successfully added")
    expect(page).to have_content(health_goal2.health_goal_name)
  end

  scenario "User must select a health goal" do
    visit new_user_health_goal_path

    # Try to submit without selecting a goal
    within("#select-existing-goal") do
      # Don't select anything from dropdown
      click_button "Add Health Goal"
    end

    # Should see validation error
    expect(page).to have_content("Health goal must exist")
  end

  scenario "User cannot add a health goal they already have" do
    # First add health_goal2
    create(:user_health_goal, user: user, health_goal: health_goal2)

    visit new_user_health_goal_path

    # Check dropdown options
    within("#select-existing-goal") do
      dropdown_options = page.all('select#user_health_goal_health_goal_id option').map(&:text)
      expect(dropdown_options).not_to include(health_goal1.health_goal_name) # Already added
      expect(dropdown_options).not_to include(health_goal2.health_goal_name) # Already added
      expect(dropdown_options).to include(health_goal3.health_goal_name) # Available
    end
  end
end
