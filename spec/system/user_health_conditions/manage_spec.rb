# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Managing health conditions", type: :system do
  let(:user) { create(:user) }
  let!(:health_condition1) { create(:health_condition, health_condition_name: "Diabetes") }
  let!(:health_condition2) { create(:health_condition, health_condition_name: "Hypertension") }
  
  before do
    user.confirm
    sign_in user
    # Create user health conditions
    create(:user_health_condition, user: user, health_condition: health_condition1)
    create(:user_health_condition, user: user, health_condition: health_condition2)
  end

  scenario "User can view their health conditions" do
    visit user_health_conditions_path
    
    expect(page).to have_content("My Health Conditions")
    expect(page).to have_content(health_condition1.health_condition_name)
    expect(page).to have_content(health_condition2.health_condition_name)
  end

  scenario "User can delete a health condition", js: true do
    visit user_health_conditions_path
    
    # Find and click delete button for health_condition2
    within("li", text: health_condition2.health_condition_name) do
      accept_confirm do
        click_button "Delete"
      end
    end
    
    # Verify the deletion
    expect(page).to have_current_path(user_health_conditions_path)
    expect(page).to have_content("Health condition was successfully removed")
    expect(page).not_to have_content(health_condition2.health_condition_name)
    expect(page).to have_content(health_condition1.health_condition_name) # Other condition still there
  end
  
  scenario "User sees empty state when no conditions are present" do
    # Remove all conditions
    UserHealthCondition.destroy_all
    
    visit user_health_conditions_path
    
    expect(page).to have_content("No health conditions added yet")
    expect(page).to have_link("Add Health Condition")
  end
end