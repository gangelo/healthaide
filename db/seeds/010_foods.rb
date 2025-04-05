puts "Creating foods..."

COMMON_FOOD_QUALIFIERS = [
  "Organic"
]

Food.find_or_create_by!(food_name: "Almond butter")
Food.find_or_create_by!(food_name: "Almonds")
Food.find_or_create_by!(food_name: "Asparagus")
Food.find_or_create_by!(food_name: "Avocado")
Food.find_or_create_by!(food_name: "Banana")
Food.find_or_create_by!(food_name: "Broccoli rabe")
Food.find_or_create_by!(food_name: "Broccolini")
Food.find_or_create_by!(food_name: "Butternut squash")
Food.find_or_create_by!(food_name: "Carrots")
Food.find_or_create_by!(food_name: "Chia seeds")
Food.find_or_create_by!(food_name: "Chicken")
Food.find_or_create_by!(food_name: "Ginger")
Food.find_or_create_by!(food_name: "Manuka honey")
Food.find_or_create_by!(food_name: "Natto")
Food.find_or_create_by!(food_name: "Pecans")
Food.find_or_create_by!(food_name: "Pepitas")
Food.find_or_create_by!(food_name: "Salmon")
Food.find_or_create_by!(food_name: "Sardines")
Food.find_or_create_by!(food_name: "Seaweed")
Food.find_or_create_by!(food_name: "Spinach")
Food.find_or_create_by!(food_name: "Sweet potato")
Food.find_or_create_by!(food_name: "Tuna")
Food.find_or_create_by!(food_name: "Turkey")
Food.find_or_create_by!(food_name: "Turmeric")

puts "Adding common food qualifiers to foods..."

Food.all.each do |food|
  COMMON_FOOD_QUALIFIERS.each do |qualifier_name|
    Food.new(food_name: food.food_name).tap do |food|
      food.food_qualifiers << FoodQualifier.find_by(qualifier_name: qualifier_name)
      food.save
    end
  end
end
