puts "Creating foods..."

FOODS = [
  "Almond butter",
  "Almond",
  "Asparagus",
  "Avocado",
  "Banana",
  "Broccoli rabe",
  "Broccolini",
  "Butternut squash",
  "Carrot",
  "Chia seed",
  "Chicken",
  "Cod",
  "Ginger",
  "Beef",
  "Iceberg lettuce",
  "Kale",
  "Kiwi",
  "Lamb",
  "Lentil",
  "Mackerel",
  "Mango",
  "Manuka honey",
  "Natto",
  "Pecan",
  "Pepita",
  "Romaine lettuce",
  "Salmon",
  "Sardine",
  "Seaweed",
  "Spinach",
  "Squash, green",
  "Squash, yellow",
  "Sweet potato",
  "Tuna",
  "Turkey",
  "Turmeric",
  "Venison",
  "White potato"
]

FOODS.each do |food_name|
  Food.find_or_create_by!(food_name: food_name)
end

puts "Foods created successfully!"
