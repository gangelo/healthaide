namespace :db do
  namespace :clean do
    desc "Delete all user-related health records (health conditions, goals, foods, and food qualifiers)"
    task user_health_records: :environment do
      puts "Cleaning user health records (unsafe mode)..."
      puts

      # Check if we're in development environment
      unless Rails.env.development?
        puts "ERROR: This task is only available in development environment!"
        exit
      end

      # Delete records in the correct order to respect foreign key constraints
      deleted_counts = {
        food_food_qualifiers: FoodFoodQualifier.delete_all,
        user_foods: UserFood.delete_all,
        user_health_goals: UserHealthGoal.delete_all,
        user_health_conditions: UserHealthCondition.delete_all
      }

      # Print results
      deleted_counts.each do |model, count|
        puts "Deleted #{count} #{model.to_s.humanize.downcase}"
      end

      puts "\nDone!"
    end

    desc "Delete all user-related health records with additional safety checks"
    task user_health_records_safe: :environment do
      puts "Preparing to clean user health records (safe mode)..."
      puts

      unless Rails.env.development?
        puts "ERROR: This task is only available in development environment!"
        exit
      end

      # Get counts before deletion
      before_counts = {
        food_food_qualifiers: FoodFoodQualifier.count,
        user_foods: UserFood.count,
        user_health_goals: UserHealthGoal.count,
        user_health_conditions: UserHealthCondition.count
      }

      # Print current counts
      puts "\nCurrent record counts:"
      before_counts.each do |model, count|
        puts "#{model.to_s.humanize}: #{count}"
      end

      # Ask for confirmation
      print "\nAre you sure you want to delete these records? [y/N]: "
      response = STDIN.gets.chomp.downcase

      if response == "y"
        # Delete records in the correct order to respect foreign key constraints
        deleted_counts = {
          food_food_qualifiers: FoodFoodQualifier.delete_all,
          user_foods: UserFood.delete_all,
          user_health_goals: UserHealthGoal.delete_all,
          user_health_conditions: UserHealthCondition.delete_all
        }

        # Print results
        puts "\nDeletion results:"
        deleted_counts.each do |model, count|
          puts "Deleted #{count} #{model.to_s.humanize.downcase}"
        end

        puts "\nDone!"
      else
        puts "\nOperation cancelled."
      end
    end

    desc "Delete all foods"
    task food_records: :environment do
      puts "Preparing to clean foods records..."
      puts

      unless Rails.env.development?
        puts "ERROR: This task is only available in development environment!"
        exit
      end

      # Get counts before deletion
      before_counts = {
        foods: Food.count
      }

      # Print current counts
      puts "\nCurrent record counts:"
      before_counts.each do |model, count|
        puts "#{model.to_s.humanize}: #{count}"
      end

      # Delete records in the correct order to respect foreign key constraints
      deleted_counts = {
        foods: Food.delete_all
      }

      # Print results
      puts "\nDeletion results:"
      deleted_counts.each do |model, count|
        puts "Deleted #{count} #{model.to_s.humanize.downcase}"
      end

      puts "\nDone!"
    end

    desc "Delete all foods with additional safety checks"
    task food_records_safe: :environment do
      puts "Preparing to clean foods records (safe mode)..."
      puts

      unless Rails.env.development?
        puts "ERROR: This task is only available in development environment!"
        exit
      end

      # Get counts before deletion
      before_counts = {
        foods: Food.count
      }

      # Print current counts
      puts "\nCurrent record counts:"
      before_counts.each do |model, count|
        puts "#{model.to_s.humanize}: #{count}"
      end

      # Ask for confirmation
      print "\nAre you sure you want to delete these records? [y/N]: "
      response = STDIN.gets.chomp.downcase

      if response == "y"
        # Delete records in the correct order to respect foreign key constraints
        deleted_counts = {
          foods: Food.delete_all
        }

        # Print results
        puts "\nDeletion results:"
        deleted_counts.each do |model, count|
          puts "Deleted #{count} #{model.to_s.humanize.downcase}"
        end

        puts "\nDone!"
      else
        puts "\nOperation cancelled."
      end
    end
  end
end
