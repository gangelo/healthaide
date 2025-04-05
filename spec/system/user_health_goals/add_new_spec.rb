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
    click_link "Add Health Goal"

    expect(page).to have_content("Add Health Goal")
    expect(page).to have_content("Create New Health Goal")
    expect(page).to have_content("Select Existing Health Goal")
    expect(page).to have_content("Add Multiple Health Goals")
  end

  scenario "User can create a new health goal" do
    visit new_user_health_goal_path

    # Choose the create new goal option
    within("#create-new-goal") do
      fill_in "user_health_goal[health_goal_name]", with: "Improve Flexibility"
      click_button "Create Health Goal"
    end

    # Verify the result
    expect(page).to have_current_path(user_health_goals_path)
    expect(page).to have_content("Health goal was successfully added")
    expect(page).to have_content(/improve flexibility/i)
  end

  scenario "User cannot create a health goal with an empty name" do
    visit new_user_health_goal_path

    # Try to submit with empty name
    within("#create-new-goal") do
      fill_in "user_health_goal[health_goal_name]", with: ""
      click_button "Create Health Goal"
    end

    # Should see validation error
    expect(page).to have_content("Health goal name can't be blank")
  end

  scenario "User cannot create a duplicate health goal" do
    visit new_user_health_goal_path

    # Try to create a health goal with an existing name
    within("#create-new-goal") do
      fill_in "user_health_goal[health_goal_name]", with: existing_health_goal.health_goal_name
      click_button "Create Health Goal"
    end

    # Should see validation error
    expect(page).to have_content(/health goal name has already been taken/i)
  end
end