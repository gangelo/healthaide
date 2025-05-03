require "rails_helper"

describe Imports::ImporterService do
  subject(:importer_service) { described_class.new(import_user_hash) }

  before do
    # Make sure our import hash is established before we test.
    import_user_hash
  end

  let(:import_user) do
    user = create(:user, username: "admin")
    user.user_foods << create(:user_food, user: user, food: create(:food, food_name: "Food 1"))
    user.user_foods << create(:user_food, user: user, food: create(:food, food_name: "Food 2"))
    user.user_foods << create(:user_food, user: user, food: create(:food, food_name: "Food 3"))
    user.user_health_conditions << create(:user_health_condition, user: user, health_condition: create(:health_condition, health_condition_name: "Health Condition 1"))
    user.user_health_conditions << create(:user_health_condition, user: user, health_condition: create(:health_condition, health_condition_name: "Health Condition 2"))
    user.user_health_conditions << create(:user_health_condition, user: user, health_condition: create(:health_condition, health_condition_name: "Health Condition 3"))
    user.user_health_goals << create(:user_health_goal, user: user, order_of_importance: 1, health_goal: create(:health_goal, health_goal_name: "Health Goal 1"))
    user.user_health_goals << create(:user_health_goal, user: user, order_of_importance: 2, health_goal: create(:health_goal, health_goal_name: "Health Goal 2"))
    user.user_health_goals << create(:user_health_goal, user: user, order_of_importance: 3, health_goal: create(:health_goal, health_goal_name: "Health Goal 3"))
    user.user_supplements << create(:user_supplement, :with_components, user: user, user_supplement_name: "Supplement 1")
    user.user_supplements << create(:user_supplement, :with_components, user: user, user_supplement_name: "Supplement 2")
    user.user_supplements << create(:user_supplement, :with_components, user: user, user_supplement_name: "Supplement 3")
    user
  end
  let(:import_user_hash) { import_user.to_export_hash }

  it do
    expect(import_user.user_foods.count).to eq(3)
  end

  describe "#execute" do
    context "when successful" do
      it "does not set #message" do
        expect(importer_service.execute).to be_successful
        expect(importer_service.message).to be_blank
      end
    end

    context "when the import user does not exist" do
      let(:import_user_hash) { { user: { username: "nonexistent" } } }

      it "sets the error in #message" do
        expect(importer_service.execute).not_to be_successful
        expect(importer_service.message).to match(/Import user 'nonexistent' not found/)
      end
    end

    context "when a system error occurs trying to find the import user" do
      before do
        allow(User).to receive(:find_by!).and_raise("Boom!")
      end

      it "sets the error in #message" do
        expect(importer_service.execute).not_to be_successful
        expect(importer_service.message).to match("Error finding import user 'admin': Boom!.")
      end
    end

    context "when the user_foods in the import_user_hash exists for the user" do
      it "does not create new user_foods or update existing user_foods" do
        expect(import_user.user_foods.count).to eq(3)
        expected_user_foods = import_user.user_foods.order(:food_id).pluck(:food_id, :available, :favorite, :updated_at)

        expect(importer_service.execute).to be_successful

        import_user.reload
        actual_user_foods = import_user.user_foods.order(:food_id).pluck(:food_id, :available, :favorite, :updated_at)

        expect(expected_user_foods).to match(actual_user_foods)
      end
    end

    context "when some, but not all, of the user_foods in the import_user_hash exist for the user" do
      it "create new user_foods but does not update existing user_foods" do
        expect(import_user.user_foods.count).to eq(3)
        expected_user_foods = import_user.user_foods.order(:food_id).pluck(:food_id, :available, :favorite, :updated_at)

        # Delete the second of the 3 user foods for the user.
        import_user.user_foods.order(:food_id).second.destroy
        import_user.reload
        expect(import_user.user_foods.count).to eq(2)

        expect(importer_service.execute).to be_successful

        # Check to see that the one user_food that was deleted was recreated (or at least that something was created).
        import_user.reload
        expect(import_user.user_foods.count).to eq(3)

        actual_user_foods = import_user.user_foods.order(:food_id).pluck(:food_id, :available, :favorite, :updated_at)

        # Compare everything except the :updated_at timestamp; this ensures that the new user_food was created
        # and the existing user_foods were not deleted.
        expect(expected_user_foods.map { |it| it[0..2] }).to match(actual_user_foods.map { |it| it[0..2] })

        # Check to see that the existing user_foods were not updated (we're comparing :updated_at times).
        expect(expected_user_foods[0]).to eq(actual_user_foods[0])
        expect(expected_user_foods[2]).to eq(actual_user_foods[2])
      end
    end

    context "when the user_foods in the import_user_hash do not exist for the user" do
      it "creates the new user_foods" do
        expect(import_user.user_foods.count).to eq(3)
        import_user.user_foods.destroy_all
        expect(import_user.user_foods.count).to be_zero
        expect(importer_service.execute).to be_successful
        import_user.reload
        expect(import_user.user_foods.count).to eq(3)
      end
    end
  end
end
