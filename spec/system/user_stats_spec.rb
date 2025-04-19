require 'rails_helper'

RSpec.describe "User Stats", type: :system do
  let(:user) { create(:user) }

  before do
    user.confirm
    sign_in user
  end

  scenario "User creates stats for the first time", js: true do
    visit user_stats_path

    # Should be redirected to new stats form
    expect(page).to have_current_path(new_user_stat_path)
    expect(page).to have_content("Enter Your Stats")
    
    # Fill in basic stats
    fill_in "Birthday", with: "2000-01-01"
    select "Male", from: "Sex"
    fill_in "Height (inches)", with: "70"
    
    # Fill in some body measurements
    fill_in "Weight (lbs)", with: "175"
    fill_in "BMI (kg/m²)", with: "24.5"
    fill_in "Percent Body Fat (%)", with: "18.5"
    select "Balanced", from: "Body Balance (Upper/Lower)"
    
    # Submit the form
    find('input[type="submit"]').click
    
    # Should be redirected to edit page with success message
    expect(page).to have_content("Your stats were successfully saved")
    expect(page).to have_content("Your Stats")
    
    # Check if data was saved correctly
    expect(user.reload.user_stat).to be_present
    expect(user.user_stat.height).to eq(70)
    expect(user.user_stat.muscle_fat_analysis_weight).to eq(175)
  end
  
  context "when user already has stats" do
    let!(:user_stat) { create(:user_stat, user: user) }
    
    scenario "User updates their stats", js: true do
      visit user_stats_path
      
      # Should be redirected to edit page
      expect(page).to have_current_path(edit_user_stat_path(user_stat))
      expect(page).to have_content("Your Stats")
      
      # Update some values
      fill_in "Weight (lbs)", with: "180"
      fill_in "Body Fat Mass (lbs)", with: "30"
      
      # Submit the form
      find('input[type="submit"]').click
      
      # Should stay on edit page with success message
      expect(page).to have_content("Your stats were successfully updated")
      expect(page).to have_content("Your Stats")
      
      # Check if data was updated correctly
      expect(user.reload.user_stat.muscle_fat_analysis_weight).to eq(180)
      expect(user.user_stat.muscle_fat_analysis_body_fat_mass).to eq(30)
    end
    
    scenario "User navigates to stats through menu", js: true do
      visit root_path
      
      # Click on My Stats in the navigation (first instance in desktop nav)
      find('div.lg\\:ml-6', match: :first).click_link "My Stats"
      
      # Should go to edit page
      expect(page).to have_current_path(edit_user_stat_path(user_stat))
      expect(page).to have_content("Your Stats")
    end
  end
end
