# frozen_string_literal: true

module Imports
  class ImporterService
    include FormattedError

    attr_reader :import_user, :import_user_hash, :message

    def initialize(import_user_hash)
      @import_user_hash = import_user_hash.with_indifferent_access
      @message          = "#execute has not been called!"
    end

    def execute
      set_import_user
      import_user_foods        if successful?
      import_user_conditions   if successful?
      import_user_health_goals if successful?
      import_user_supplements  if successful?
      import_user_medications  if successful?
      import_user_stats        if successful?
      import_user_meal_prompt  if successful?

      self
    end

    def successful?
      @message.blank?
    end

    private

    def set_import_user
      begin
        username = @import_user_hash.dig(:user, :username)
        @import_user = User.find_by!(username: username)
        @message = nil
      rescue ActiveRecord::RecordNotFound => e
        @message = format_error("Import user '#{username}' not found", error: e)
      rescue => e
        @message = format_error("Error finding import user '#{username}'", error: e)
      end
    end

    def import_user_foods
      begin
        user_foods_hash = @import_user_hash.dig(:user, :user_foods)
        user_foods_hash.each do |user_food_hash|
          food_name = user_food_hash.dig(:user_food, :food, :food_name)
          Rails.logger.info "Importing user food: '#{food_name}' for user: #{@import_user.username}..."

          food = Food.find_by(food_name: food_name)
          next if food.nil?

          @import_user.user_foods.find_or_initialize_by(food_id: food.id).tap do |x|
            x.save!
          end
        end
        @message = nil
      rescue ActiveRecord::RecordInvalid => e
        @message = format_error("Error importing user foods", error: e)
      rescue => e
        @message = format_error("Error importing user foods", error: e)
      end
    end

    def import_user_conditions
      begin
        user_health_conditions_hash = @import_user_hash.dig(:user, :user_health_conditions)
        user_health_conditions_hash.each do |user_health_condition_hash|
          health_condition_name = user_health_condition_hash.dig(:user_health_condition, :health_condition, :health_condition_name)
          Rails.logger.info "Importing user health condition: '#{health_condition_name}' for user: #{@import_user.username}..."

          health_condition = HealthCondition.find_by(health_condition_name: health_condition_name)
          next if health_condition.nil?

          @import_user.user_health_conditions.find_or_initialize_by(health_condition_id: health_condition.id).tap do |x|
            x.save! if x.new_record?
          end
        end
        @message = nil
      rescue ActiveRecord::RecordInvalid => e
        @message = format_error("Error importing user health conditions", error: e)
      rescue => e
        @message = format_error("Error importing user health conditions", error: e)
      end
    end

    def import_user_health_goals
      begin
        user_health_goals_hash = @import_user_hash.dig(:user, :user_health_goals)
        user_health_goals_hash.each do |user_health_goal_hash|
          health_goal_name = user_health_goal_hash.dig(:user_health_goal, :health_goal, :health_goal_name)
          Rails.logger.info "Importing user health goal: '#{health_goal_name}' for user: #{@import_user.username}..."

          health_goal = HealthGoal.find_by(health_goal_name: health_goal_name)
          next if health_goal.nil?

          @import_user.user_health_goals.find_or_initialize_by(health_goal_id: health_goal.id).tap do |x|
            x.order_of_importance = user_health_goal_hash[:user_health_goal][:order_of_importance]
            x.save!
          end
        end
        @message = nil
      rescue ActiveRecord::RecordInvalid => e
        @message = format_error("Error importing user health goal", error: e)
      rescue => e
        @message = format_error("Error importing user health goals", error: e)
      end
    end

    def import_user_supplements
      begin
        user_supplements_hash = @import_user_hash.dig(:user, :user_supplements)
        user_supplements_hash.each do |user_supplement_hash|
          user_supplement_hash = user_supplement_hash[:user_supplement]
          user_supplement_name = user_supplement_hash[:user_supplement_name]
          Rails.logger.info "Importing user supplement: '#{user_supplement_name}' for user: #{@import_user.username}..."

          @import_user.user_supplements.find_or_initialize_by(user_supplement_name: user_supplement_name).tap do |user_supplement|
            user_supplement.form         = user_supplement_hash[:form]
            user_supplement.frequency    = user_supplement_hash[:frequency]
            user_supplement.dosage       = user_supplement_hash[:dosage]
            user_supplement.dosage_unit  = user_supplement_hash[:dosage_unit]
            user_supplement.manufacturer = user_supplement_hash[:manufacturer]
            user_supplement.notes        = user_supplement_hash[:notes]

            user_supplement.save!

            import_user_supplement_components!(user_supplement:, user_supplement_hash:)
          end
        end
        @message = nil
      rescue ActiveRecord::RecordInvalid => e
        @message = format_error("Error importing user supplements", error: e)
      rescue => e
        @message = format_error("Error importing user supplements", error: e)
      end
    end

    def import_user_supplement_components!(user_supplement:, user_supplement_hash:)
      user_supplement.supplement_components = []

      return if user_supplement_hash.blank?

      user_supplement_hash[:supplement_components].each do |user_supplement_component_hash|
        user_supplement_component_hash = user_supplement_component_hash[:supplement_component]
        user_supplement.supplement_components.create!(user_supplement_component_hash.slice(:supplement_component_name, :amount, :unit))
      end
    rescue ActiveRecord::RecordInvalid => e
      @message = format_error("Error importing user supplement components", error: e)
    rescue => e
      @message = format_error("Error importing user supplement components", error: e)
    end

    def import_user_medications
      begin
        user_medications_hash = @import_user_hash.dig(:user, :user_medications)
        user_medications_hash.each do |user_medication_hash|
          user_medication_hash = user_medication_hash[:user_medication]
          medication_name      = user_medication_hash[:medication][:medication_name]
          Rails.logger.info "Importing user medication: '#{medication_name}' for user: #{@import_user.username}..."

          next if medication_name.blank?

          medication = Medication.find_or_initialize_by(medication_name:)
          Rails.logger.debug("xyzzy: medication_name: #{medication_name}")
          Rails.logger.debug("xyzzy: medication: #{medication.inspect}")

          @import_user.user_medications.find_or_initialize_by(medication:).tap do |user_medication|
            user_medication.frequency = user_medication_hash[:frequency]

            user_medication.save!
          end
        end
        @message = nil
      rescue ActiveRecord::RecordInvalid => e
        @message = format_error("Error importing user medications", error: e)
      rescue => e
        @message = format_error("Error importing user medications", error: e)
      end
    end

    def import_user_stats
      begin
        user_stats_hash = @import_user_hash.dig(:user, :user_stat)
        @import_user.user_stat&.destroy

        if user_stats_hash.present?
          user_stat = @import_user.build_user_stat
          user_stat.update!(**filter_model_hash(user_stats_hash))
        end
        @message = nil
      rescue ActiveRecord::RecordInvalid => e
        @message = format_error("Error importing user stat", error: e)
      rescue => e
        @message = format_error("Error importing user stats", error: e)
      end
    end

    def import_user_meal_prompt
      begin
        meal_prompt_hash = @import_user_hash.dig(:user, :user_meal_prompt)
        Rails.logger.info "Importing user meal prompt for user: #{@import_user.username}..."

        return if meal_prompt_hash.blank?

        user_meal_prompt = UserMealPrompt.find_by_username(@import_user.username)&.first
        user_meal_prompt ||= @import_user.build_user_meal_prompt

        filtered_meal_prompt_hash = filter_model_hash(meal_prompt_hash)
        user_meal_prompt.update!(**filtered_meal_prompt_hash)

        @message = nil
      rescue ActiveRecord::RecordInvalid => e
        @message = format_error("Error importing meal prompt", error: e)
      rescue => e
        @message = format_error("Error importing meal prompt", error: e)
      end
    end

    def filter_model_hash(model_hash)
      return {} unless model_hash.is_a?(Hash)

      model_hash.reject do |key, value|
        %i[created_at id user_id updated_at].include?(key.to_sym)
      end
    end
  end
end
