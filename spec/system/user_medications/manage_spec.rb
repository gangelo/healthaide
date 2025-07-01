# frozen_string_literal: true

RSpec.describe "Managing medications", type: :system do
  let(:user) { create(:user) }
  let!(:medication1) { create(:medication, medication_name: "Aspirin") }
  let!(:medication2) { create(:medication, medication_name: "Ibuprofen") }

  before do
    user.confirm
    sign_in user
    # Create user medications with frequency
    create(:user_medication, user: user, medication: medication1, frequency: :daily)
    create(:user_medication, user: user, medication: medication2, frequency: :twice_daily)
  end

  scenario "User can view their medications with frequency" do
    visit user_medications_path

    expect(page).to have_content("Medications")
    expect(page).to have_content(medication1.medication_name)
    expect(page).to have_content(medication2.medication_name)
    expect(page).to have_content("Taken daily")
    expect(page).to have_content("Taken twice daily")
  end

  scenario "User can show a medication" do
    visit user_medications_path

    # Find and click show button for medication1
    within("#medication-id-#{medication1.id}") do
      click_link "Show"
    end

    expect(page).to have_current_path(user_medication_path(UserMedication.find_by(user: user, medication: medication1)))
    expect(page).to have_content("Medication")
    expect(page).to have_content(medication1.medication_name)
    expect(page).to have_content("Taken daily")
  end

  scenario "User can edit a medication frequency" do
    user_medication = UserMedication.find_by(user: user, medication: medication1)
    visit user_medications_path

    # Find and click edit button for medication1
    within("#medication-id-#{medication1.id}") do
      click_link "Edit"
    end

    expect(page).to have_current_path(edit_user_medication_path(user_medication))
    expect(page).to have_content("Edit Medication")
    expect(page).to have_content(medication1.medication_name)

    # Change frequency
    select "Weekly", from: "Frequency"
    find('input[type="submit"][value*="Update"]').click

    expect(page).to have_current_path(user_medications_path)
    expect(page).to have_content("Medication was successfully updated")
    expect(page).to have_content("Taken weekly")
  end

  scenario "User can delete a medication from index page", js: true do
    visit user_medications_path

    # Find and click delete button for medication2
    within("#medication-id-#{medication2.id}", text: medication2.medication_name) do
      accept_confirm do
        click_button "Delete"
      end
    end

    # Verify the deletion
    expect(page).to have_current_path(user_medications_path)
    expect(page).to have_content("Medication was successfully removed")
    expect(page).not_to have_content(medication2.medication_name)
    expect(page).to have_content(medication1.medication_name) # Other medication still there
  end

  scenario "User sees empty state when no medications are present" do
    # Remove all medications
    UserMedication.destroy_all

    visit user_medications_path

    expect(page).to have_content("No medications added yet")
    expect(page).to have_link("Add Medication")
  end

  context "when adding new medication with frequency" do
    scenario "User can add medication with frequency selection" do
      visit user_medications_path
      click_link "Add Medication"

      expect(page).to have_current_path(new_user_medication_path)
      expect(page).to have_content("Add Medication")
      expect(page).to have_field("Frequency")

      # Select frequency before adding medication
      select "Three times daily", from: "Frequency"

      # The medication search functionality would be tested separately
      # For now just verify the frequency field is present and required
      expect(page).to have_select("Frequency", selected: "Three times daily")
    end
  end
end
