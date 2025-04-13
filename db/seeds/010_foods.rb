puts "Creating foods..."

COMMON_FOOD_QUALIFIERS = [
  "Organic"
]

Food.find_or_create_by!(food_name: "Almond butter")
Food.find_or_create_by!(food_name: "Almond")
Food.find_or_create_by!(food_name: "Asparagus")
Food.find_or_create_by!(food_name: "Avocado")
Food.find_or_create_by!(food_name: "Banana")
Food.find_or_create_by!(food_name: "Broccoli rabe")
Food.find_or_create_by!(food_name: "Broccolini")
Food.find_or_create_by!(food_name: "Butternut squash")
Food.find_or_create_by!(food_name: "Carrot")
Food.find_or_create_by!(food_name: "Chia seed")
Food.find_or_create_by!(food_name: "Chicken")
Food.find_or_create_by!(food_name: "Cod")
Food.find_or_create_by!(food_name: "Ginger")
Food.find_or_create_by!(food_name: "Beef")
Food.find_or_create_by!(food_name: "Iceberg lettuce")
Food.find_or_create_by!(food_name: "Kale")
Food.find_or_create_by!(food_name: "Kiwi")
Food.find_or_create_by!(food_name: "Lamd")
Food.find_or_create_by!(food_name: "Lentil")
Food.find_or_create_by!(food_name: "Lettuce")
Food.find_or_create_by!(food_name: "Mackerel")
Food.find_or_create_by!(food_name: "Mango")
Food.find_or_create_by!(food_name: "Manuka honey")
Food.find_or_create_by!(food_name: "Natto")
Food.find_or_create_by!(food_name: "Pecan")
Food.find_or_create_by!(food_name: "Pepita")
Food.find_or_create_by!(food_name: "Romaine lettuce")
Food.find_or_create_by!(food_name: "Salmon")
Food.find_or_create_by!(food_name: "Sardine")
Food.find_or_create_by!(food_name: "Seaweed")
Food.find_or_create_by!(food_name: "Spinach")
Food.find_or_create_by!(food_name: "Sweet potato")
Food.find_or_create_by!(food_name: "Tuna")
Food.find_or_create_by!(food_name: "Turkey")
Food.find_or_create_by!(food_name: "Turmeric")

puts "- Adding common food qualifiers to foods..."

Food.all.each do |food|
  COMMON_FOOD_QUALIFIERS.each do |qualifier_name|
    Food.new(food_name: food.food_name).tap do |food|
      food.food_qualifiers << FoodQualifier.find_by(qualifier_name: qualifier_name)
      food.save
    end
  end
end
