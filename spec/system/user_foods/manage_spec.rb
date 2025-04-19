# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Managing foods", type: :system do
  let(:user) { create(:user) }
  let!(:food1) { create(:food, food_name: "Apple") }
  let!(:food2) { create(:food, food_name: "Banana") }

  # Food with qualifiers
  let!(:food_with_qualifiers) do
    food = create(:food, food_name: "Avocado")
    food.food_qualifiers << create(:food_qualifier, qualifier_name: "Organic")
    food.food_qualifiers << create(:food_qualifier, qualifier_name: "Fresh")
    food
  end

  before do
    user.confirm
    sign_in user
    # Create user foods
    create(:user_food, user: user, food: food1)
    create(:user_food, user: user, food: food2)
    create(:user_food, user: user, food: food_with_qualifiers)
  end

  scenario "User can view their foods" do
    visit user_foods_path

    expect(page).to have_content("My Foods")
    expect(page).to have_content(food1.food_name)
    expect(page).to have_content(food2.food_name)
    expect(page).to have_content(food_with_qualifiers.food_name)

    # Should display qualifiers
    expect(page).to have_content("Organic")
    expect(page).to have_content("Fresh")
  end

  scenario "User can delete a food from index page", js: true do
    visit user_foods_path

    # Find and click delete button for food2
    within("#food-id-#{food2.id}", text: food2.food_name) do
      accept_confirm do
        click_button "Delete"
      end
    end

    # Verify the deletion
    expect(page).to have_current_path(user_foods_path)
    expect(page).to have_content("Food was successfully removed")
    expect(page).not_to have_content(food2.food_name)
    expect(page).to have_content(food1.food_name) # Other food still there
  end

  scenario "User sees empty state when no foods are present" do
    # Remove all foods
    UserFood.destroy_all

    visit user_foods_path

    expect(page).to have_content("No foods added yet")
    expect(page).to have_link("Add Food")
  end
end
