# .irbrc
if defined?(Rails::Console)
  begin
    require 'factory_bot'
    require 'ffaker'

    if defined?(FactoryBot)
      include FactoryBot::Syntax::Methods
      puts "✅ FactoryBot loaded! You can use create(:model) without the FactoryBot prefix."
    end

    if defined?(FFaker)
      puts "✅ FFaker loaded!"
    end

    puts "\nReady to use factories and fake data!"
  rescue LoadError => e
    puts "⚠️ Warning: Could not load gems: #{e.message}"
  end
end
