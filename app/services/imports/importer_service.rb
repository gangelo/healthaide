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
      import_user_stats        if successful?

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
        user_foods = @import_user_hash.dig(:user, :user_foods)
        user_foods.each do |user_food|
          food_name = user_food.dig(:user_food, :food, :food_name)
          Rails.logger.info "Importing user food: '#{food_name}' for user: #{@import_user.username}..."

          food = Food.find_by(food_name: food_name)
          next if food.nil?

          @import_user.user_foods.find_or_initialize_by(food_id: food.id).tap do |u|
            if u.new_record?
              u.available = user_food[:user_food][:available]
              u.favorite  = user_food[:user_food][:favorite]
              u.save!
            end
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
        user_health_conditions = @import_user_hash.dig(:user, :user_health_conditions)
        user_health_conditions.each do |user_health_condition|
          health_condition_name = user_health_condition.dig(:user_health_condition, :health_condition, :health_condition_name)
          Rails.logger.info "Importing user health condition: '#{health_condition_name}' for user: #{@import_user.username}..."

          health_condition = HealthCondition.find_by(health_condition_name: health_condition_name)
          next if health_condition.nil?

          @import_user.user_health_conditions.find_or_initialize_by(health_condition_id: health_condition.id).tap do |h|
            h.save! if h.new_record?
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
        user_health_goals = @import_user_hash.dig(:user, :user_health_goals)
        user_health_goals.each do |user_health_goal|
          health_goal_name = user_health_goal.dig(:user_health_goal, :health_goal, :health_goal_name)
          Rails.logger.info "Importing user health goal: '#{health_goal_name}' for user: #{@import_user.username}..."

          health_goal = HealthGoal.find_by(health_goal_name: health_goal_name)
          next if health_goal.nil?

          @import_user.user_health_goals.find_or_initialize_by(health_goal_id: health_goal.id).tap do |g|
            if g.new_record?
              g.order_of_importance = user_health_goal[:user_health_goal][:order_of_importance]
              g.save!
            end
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
      # Skip supplements import for now as it's not implemented yet
      @message = nil
    end

    def import_user_stats
      begin
        user_stats = @import_user_hash.dig(:user, :user_stat)
        Rails.logger.info "Importing user stats for user: #{@import_user.username}..."

        if user_stats.present?
          UserStat.find_or_initialize_by(user_id: @import_user.id).tap do |s|
            if s.new_record?
              filtered_user_stats = filter_user_stat(user_stats)
              Rails.logger.debug "Filtered user stats: '#{filtered_user_stats}' for user: #{@import_user.username}..."

              filtered_user_stats.each do |key, value|
                Rails.logger.debug "Importing user stat: '#{key}' with value: '#{value}' for user: #{@import_user.username}..."
                s.public_send("#{key}=", value)
              end
              s.save!
            end
          end
        end
        @message = nil
      rescue ActiveRecord::RecordInvalid => e
        @message = format_error("Error importing user stat", error: e)
      rescue => e
        @message = format_error("Error importing user stats", error: e)
      end
    end

    def filter_user_stat(user_stats)
      return {} unless user_stats.is_a?(Hash)
      
      user_stats.reject do |key, value|
        %i[created_at id user_id updated_at].include?(key.to_sym)
      end
    end
  end
end
