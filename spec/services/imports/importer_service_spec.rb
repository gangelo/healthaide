require "rails_helper"

RSpec.describe Imports::ImporterService do
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
    create(:user_meal_prompt, user: user)
    user
  end
  let(:import_user_hash) { import_user.to_export_hash }

  # Move this into a proper test
  describe "test setup" do
    it "creates a user with the expected associations" do
      expect(import_user.user_foods.count).to eq(3)
      expect(import_user.user_health_conditions.count).to eq(3)
      expect(import_user.user_health_goals.count).to eq(3)
      expect(import_user.user_supplements.count).to eq(3)
      expect(import_user.user_meal_prompt).to be_present
    end
  end

  describe "#execute" do
    context "when successful" do
      it "does not set #message" do
        expect(importer_service.execute).to be_successful
        expect(importer_service.message).to be_blank
      end

      it "returns a successful result" do
        result = importer_service.execute
        expect(result).to be_successful
      end
    end

    context "when the import user does not exist" do
      let(:import_user_hash) { { user: { username: "nonexistent" } } }

      it "sets the error in #message" do
        expect(importer_service.execute).not_to be_successful
        expect(importer_service.message).to match(/Import user 'nonexistent' not found/)
      end

      it "returns an unsuccessful result" do
        result = importer_service.execute
        expect(result).not_to be_successful
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

      it "returns an unsuccessful result" do
        result = importer_service.execute
        expect(result).not_to be_successful
      end
    end

    context "when the user_foods in the import_user_hash exists for the user" do
      it "does not create new user_foods or update existing user_foods" do
        expect(import_user.user_foods.count).to eq(3)
        expected_user_foods = import_user.user_foods.order(:food_id).pluck(:food_id, :updated_at)

        result = importer_service.execute
        expect(result).to be_successful

        import_user.reload
        actual_user_foods = import_user.user_foods.order(:food_id).pluck(:food_id, :updated_at)

        expect(expected_user_foods).to match(actual_user_foods)
      end
    end

    context "when some, but not all, of the user_foods in the import_user_hash exist for the user" do
      it "creates new user_foods but does not update existing user_foods" do
        expect(import_user.user_foods.count).to eq(3)
        expected_user_foods = import_user.user_foods.order(:food_id).pluck(:food_id, :updated_at)

        # Delete the second of the 3 user foods for the user.
        import_user.user_foods.order(:food_id).second.destroy
        import_user.reload
        expect(import_user.user_foods.count).to eq(2)

        result = importer_service.execute
        expect(result).to be_successful

        # Check to see that the one user_food that was deleted was recreated (or at least that something was created).
        import_user.reload
        expect(import_user.user_foods.count).to eq(3)

        actual_user_foods = import_user.user_foods.order(:food_id).pluck(:food_id, :updated_at)

        # Compare everything except the :updated_at timestamp; this ensures that the new user_food was created
        # and the existing user_foods were not deleted.
        expect(expected_user_foods.map { |it| it[0] }).to match(actual_user_foods.map { |it| it[0] })

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

        result = importer_service.execute
        expect(result).to be_successful

        import_user.reload
        expect(import_user.user_foods.count).to eq(3)
      end
    end

    # Additional tests that might help exercise functionality
    context "when testing other associated objects" do
      it "handles user_health_conditions properly" do
        expect(import_user.user_health_conditions.count).to eq(3)
        import_user.user_health_conditions.destroy_all
        expect(import_user.user_health_conditions.count).to be_zero

        result = importer_service.execute
        expect(result).to be_successful

        import_user.reload
        expect(import_user.user_health_conditions.count).to eq(3)
      end

      it "handles user_health_goals properly" do
        original_count = import_user.user_health_goals.count
        import_user.user_health_goals.destroy_all
        expect(import_user.user_health_goals.count).to be_zero

        result = importer_service.execute
        expect(result).to be_successful

        import_user.reload
        expect(import_user.user_health_goals.count).to eq(original_count)
      end

      it "handles user_supplements properly" do
        original_count = import_user.user_supplements.count
        original_components_count = SupplementComponent.joins(:user_supplement)
                                   .where(user_supplements: { user_id: import_user.id })
                                   .count

        import_user.user_supplements.destroy_all
        expect(import_user.user_supplements.count).to be_zero

        result = importer_service.execute
        expect(result).to be_successful

        import_user.reload
        expect(import_user.user_supplements.count).to eq(original_count)
        expect(SupplementComponent.joins(:user_supplement)
                                  .where(user_supplements: { user_id: import_user.id })
                                  .count).to eq(original_components_count)
      end

      it "handles user_meal_prompt properly when no existing meal prompt exists" do
        # Delete existing meal prompt
        import_user.user_meal_prompt.destroy
        import_user.reload
        expect(import_user.user_meal_prompt).to be_nil

        # Add meal prompt data to import hash if not present
        if import_user_hash[:user][:user_meal_prompt].nil?
          import_user_hash[:user][:user_meal_prompt] = {
            meals_count: 3,
            include_user_stats: true,
            food_ids: [],
            health_condition_ids: [],
            health_goal_ids: [],
            user_supplement_ids: []
          }
        end

        result = importer_service.execute
        expect(result).to be_successful

        import_user.reload
        expect(import_user.user_meal_prompt).to be_present
        expect(import_user.user_meal_prompt.meals_count).not_to be_nil
      end

      it "handles user_meal_prompt properly when updating an existing meal prompt" do
        # Create a meal prompt if it doesn't exist
        unless import_user.user_meal_prompt
          create(:user_meal_prompt, user: import_user)
          import_user.reload
        end

        # Save original meal prompt data
        original_prompt = import_user.user_meal_prompt
        original_meals_count = original_prompt.meals_count
        new_meals_count = original_meals_count + 2

        # Modify the import hash to have different values
        modified_hash = import_user_hash.deep_dup
        if modified_hash[:user][:user_meal_prompt].nil?
          modified_hash[:user][:user_meal_prompt] = {
            meals_count: new_meals_count
          }
        else
          modified_hash[:user][:user_meal_prompt][:meals_count] = new_meals_count
        end

        # Create a new importer with the modified hash
        modified_importer = described_class.new(modified_hash)

        # Execute and verify
        expect(import_user.user_meal_prompt.meals_count).to eq(original_meals_count)
        result = modified_importer.execute
        expect(result).to be_successful

        import_user.reload
        expect(import_user.user_meal_prompt.meals_count).to eq(new_meals_count)
      end

      it "does not create a user_meal_prompt when not included in the import hash" do
        # Delete existing meal prompt
        import_user.user_meal_prompt.destroy
        import_user.reload
        expect(import_user.user_meal_prompt).to be_nil

        # Create a new hash without meal prompt data
        hash_without_meal_prompt = import_user_hash.deep_dup
        hash_without_meal_prompt[:user].delete(:user_meal_prompt) if hash_without_meal_prompt[:user][:user_meal_prompt]
        no_meal_prompt_importer = described_class.new(hash_without_meal_prompt)

        result = no_meal_prompt_importer.execute
        expect(result).to be_successful

        import_user.reload
        expect(import_user.user_meal_prompt).to be_nil
      end

      it "handles errors during meal prompt import" do
        # Setup to generate an error
        allow_any_instance_of(UserMealPrompt).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(UserMealPrompt.new))

        # Make sure meal prompt data exists in the hash
        if import_user_hash[:user][:user_meal_prompt].nil?
          import_user_hash[:user][:user_meal_prompt][:meals_count] = 3
        end

        result = importer_service.execute
        expect(result).not_to be_successful
        expect(result.message).to match(/Error importing meal prompt/)
      end

      context "user_stats tests" do
        before do
          # Ensure there's user_stat data in the hash
          import_user_hash[:user][:user_stat] = { muscle_fat_analysis_weight: 75, height: 96 } unless import_user_hash[:user][:user_stat]
        end

        it "handles user_stats properly when no existing stats exist" do
          # Delete existing user stats
          import_user.user_stat&.destroy
          import_user.reload
          expect(import_user.user_stat).to be_nil

          result = importer_service.execute
          expect(result).to be_successful

          import_user.reload
          expect(import_user.user_stat).to be_present
        end

        it "handles user_stats properly when updating existing stats" do
          # Create user stats if needed
          unless import_user.user_stat
            create(:user_stat, user: import_user, muscle_fat_analysis_weight: 70)
            import_user.reload
          end

          new_weight = (import_user.user_stat.muscle_fat_analysis_weight || 100) + 1
          new_height = (import_user.user_stat.height || 70) + 1

          # Modify the import hash
          modified_hash = import_user_hash.deep_dup
          modified_hash[:user][:user_stat] = { muscle_fat_analysis_weight: new_weight, height: new_height }

          # Create a new importer with the modified hash
          modified_importer = described_class.new(modified_hash)

          # Execute and verify
          result = modified_importer.execute
          expect(result).to be_successful

          import_user.reload
          expect(import_user.user_stat.muscle_fat_analysis_weight).to eq(new_weight)
          expect(import_user.user_stat.height).to eq(new_height)
        end

        it "removes existing user stats when not included in the import hash" do
          # Ensure user has stats
          unless import_user.user_stat
            create(:user_stat, user: import_user, muscle_fat_analysis_weight: 70)
            import_user.reload
          end
          expect(import_user.user_stat).to be_present

          # Create a new hash without user stat data
          hash_without_stats = import_user_hash.deep_dup
          hash_without_stats[:user].delete(:user_stat)
          no_stats_importer = described_class.new(hash_without_stats)

          result = no_stats_importer.execute
          expect(result).to be_successful

          import_user.reload
          expect(import_user.user_stat).to be_nil
        end

        it "handles errors during user stats import" do
          # Setup to generate an error
          allow_any_instance_of(UserStat).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(UserStat.new))

          result = importer_service.execute
          expect(result).not_to be_successful
          expect(result.message).to match(/Error importing user stat/)
        end
      end
    end
  end
end
