# frozen_string_literal: true

RSpec.describe "Medications Management", type: :system do
  let(:user) { create(:user, :admin) }

  before do
    # Confirm the user and sign in using helper
    user.confirm
    sign_in user
  end

  describe "viewing medications index" do
    it "displays medications navigation link" do
      visit root_path
      
      # Check that the medications link is present in the admin menu
      expect(page).to have_link("Medications", href: medications_path)
    end

    it "displays all medications" do
      # Create medications with valid names
      create(:medication, medication_name: "Aspirin")
      create(:medication, medication_name: "Ibuprofen")

      visit medications_path

      expect(page).to have_content("Medications")
      expect(page).to have_content("Aspirin")
      expect(page).to have_content("Ibuprofen")
    end

    it "shows empty state when no medications exist" do
      visit medications_path

      expect(page).to have_content("No medications found")
      expect(page).to have_content("Medications are managed through external data sources")
    end

    it "does not show Add New Medication button" do
      visit medications_path

      expect(page).not_to have_link("Add New Medication")
      expect(page).not_to have_button("Add New Medication")
    end
  end

  describe "viewing a medication" do
    let!(:medication) { create(:medication, medication_name: "Acetaminophen") }

    it "displays medication details" do
      visit medication_path(medication)

      expect(page).to have_content("Medication")
      expect(page).to have_content(medication.medication_name)
      expect(page).to have_content("Unused")
    end

    it "shows usage status when medication is in use" do
      user_medication = create(:user_medication, medication: medication)

      visit medication_path(medication)

      expect(page).to have_content("In use (1)")
    end

    it "does not show Edit button" do
      visit medication_path(medication)

      expect(page).not_to have_link("Edit this Medication")
      expect(page).not_to have_button("Edit this Medication")
    end

    it "shows Back to Medications button" do
      visit medication_path(medication)

      expect(page).to have_link("Back to Medications", href: medications_path)
    end

    it "shows Delete button when medication is not in use" do
      visit medication_path(medication)

      expect(page).to have_button("Delete this Medication")
    end

    it "disables Delete button when medication is in use" do
      create(:user_medication, medication: medication)

      visit medication_path(medication)

      expect(page).to have_button("Delete this Medication", disabled: true)
    end
  end

  describe "deleting a medication" do
    let!(:medication) { create(:medication, medication_name: "Tylenol") }

    it "deletes the medication and displays a success message", js: true do
      visit medications_path

      # Find the row containing the medication name and click its delete button
      within("li", text: medication.medication_name) do
        click_button "Delete"
      end

      # Accept the confirmation dialog
      accept_confirm

      # Check for success message
      expect(page).to have_content("Medication was successfully removed")

      # Medication should be completely removed
      expect(page).not_to have_content("Tylenol")

      # Medication should be deleted from the database
      expect(Medication.find_by(id: medication.id)).to be_nil
    end

    it "prevents deletion when medication is in use", js: true do
      create(:user_medication, medication: medication)

      visit medications_path

      # Find the row containing the medication name
      within("li", text: medication.medication_name) do
        expect(page).to have_button("Delete", disabled: true)
      end

      # Medication should still exist in database
      expect(Medication.find_by(id: medication.id)).to be_present
    end
  end

  describe "pagination" do
    it "shows page size selector" do
      visit medications_path

      expect(page).to have_select("pager_rows_select")
    end

    it "handles large number of medications with pagination" do
      # Create more medications than the default page size
      25.times do |i|
        create(:medication, medication_name: "Medication #{i.to_s.rjust(3, '0')}")
      end

      visit medications_path

      # Should show pagination controls
      expect(page).to have_css("#pagination_controls")
      
      # Should show first page of results
      expect(page).to have_content("Medication 000")
    end
  end

  describe "navigation flow" do
    let!(:medication) { create(:medication, medication_name: "Metformin") }

    it "allows navigation from index to show and back" do
      visit medications_path

      # Click show button for the medication
      within("li", text: medication.medication_name) do
        click_link "Show"
      end

      # Should be on the show page
      expect(current_path).to eq(medication_path(medication))
      expect(page).to have_content("Metformin")

      # Click back button
      click_link "Back to Medications"

      # Should be back on index page
      expect(current_path).to eq(medications_path)
      expect(page).to have_content("Medications")
    end
  end
end