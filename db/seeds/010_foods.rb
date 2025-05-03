puts "Creating foods with qualifiers..."

FOODS_WITH_QUALIFIERS = {
  "Almond butter"     => { food_qualifiers: [ "Organic", "Raw", "Roasted", "Salted", "Salt-free" ] },
  "Almond"            => { food_qualifiers: [ "Chopped", "Raw", "Roasted", "Salted", "Salt-free", "Sliced" ] },
  "Asparagus"         => { food_qualifiers: [ "Fresh", "Frozen", "Organic" ] },
  "Avocado"           => { food_qualifiers: [ "Fresh", "Organic" ] },
  "Banana"            => { food_qualifiers: [ "Fresh", "Organic" ] },
  "Broccoli rabe"     => { food_qualifiers: [ "Fresh", "Frozen", "Organic" ] },
  "Broccolini"        => { food_qualifiers: [ "Fresh", "Frozen", "Organic" ] },
  "Butternut squash"  => { food_qualifiers: [ "Fresh", "Frozen", "Organic" ] },
  "Carrot"            => { food_qualifiers: [ "Fresh", "Frozen", "Organic" ] },
  "Chia seed"         => { food_qualifiers: [ "Organic", "Raw" ] },
  "Chicken"           => { food_qualifiers: [ "Breast", "Thigh", "Leg", "Organic", "Fresh", "Frozen" ] },
  "Cod"               => { food_qualifiers: [ "Fresh", "Frozen", "Wild caught" ] },
  "Ginger"            => { food_qualifiers: [ "Fresh", "Organic" ] },
  "Beef"              => { food_qualifiers: [ "90/10", "80/20", "75/25", "Ground", "Organic" ] },
  "Iceberg lettuce"   => { food_qualifiers: [ "Fresh", "Organic" ] },
  "Kale"              => { food_qualifiers: [ "Fresh", "Frozen", "Organic" ] },
  "Kiwi"              => { food_qualifiers: [ "Fresh", "Organic" ] },
  "Lamb"              => { food_qualifiers: [ "Chop", "Leg", "Ground", "Organic", "Shoulder" ] },
  "Lentil"            => { food_qualifiers: [ "Organic", "Canned" ] },
  "Mackerel"          => { food_qualifiers: [ "Fresh", "Frozen", "Canned, olive oil", "Canned, spring water", "Wild caught" ] },
  "Mango"             => { food_qualifiers: [ "Fresh", "Frozen", "Organic" ] },
  "Manuka honey"      => { food_qualifiers: [ "Raw", "Organic" ] },
  "Natto"             => { food_qualifiers: [ "Organic", "Non-gmo" ] },
  "Pecan"             => { food_qualifiers: [ "Chopped", "Raw", "Roasted", "Salted", "Salt-free" ] },
  "Pepita"            => { food_qualifiers: [ "Raw", "Roasted", "Salted", "Salt-free" ] },
  "Romaine lettuce"   => { food_qualifiers: [ "Fresh", "Organic" ] },
  "Salmon"            => { food_qualifiers: [ "Fresh", "Frozen", "Canned, olive oil", "Canned, spring water", "Wild caught" ] },
  "Sardine"           => { food_qualifiers: [ "Canned, olive oil", "Canned, spring water", "Wild caught" ] },
  "Seaweed"           => { food_qualifiers: [ "Fresh", "Dried", "Organic" ] },
  "Spinach"           => { food_qualifiers: [ "Fresh", "Frozen", "Organic" ] },
  "Squash, green"     => { food_qualifiers: [ "Fresh", "Organic" ] },
  "Squash, yellow"    => { food_qualifiers: [ "Fresh", "Organic" ] },
  "Sweet potato"      => { food_qualifiers: [ "Fresh", "Organic" ] },
  "Tuna"              => { food_qualifiers: [ "Fresh", "Frozen", "Canned, olive oil", "Canned, spring water", "Wild caught" ] },
  "Turkey"            => { food_qualifiers: [ "Breast", "Ground", "Organic", "Fresh", "Frozen", "Sliced" ] },
  "Turmeric"          => { food_qualifiers: [ "Fresh", "Organic" ] },
  "Venison"           => { food_qualifiers: [ "Ground", "Organic" ] },
  "White potato"      => { food_qualifiers: [ "Fresh", "Organic" ] }
}.freeze

# First ensure all qualifiers exist
all_qualifiers = FOODS_WITH_QUALIFIERS.values.flat_map { |v| v[:food_qualifiers] }.uniq
all_qualifiers.each do |qualifier_name|
  begin
    FoodQualifier.find_or_create_by!(qualifier_name: qualifier_name)
  rescue ActiveRecord::RecordInvalid => e
    puts "Error creating FoodQualifier: #{qualifier_name} - #{e.message}"
  end
end

# Then create foods with their qualifiers
FOODS_WITH_QUALIFIERS.each do |food_name, attributes|
  food = Food.find_or_create_by!(food_name: food_name)

  # Add qualifiers to the food
  attributes[:food_qualifiers].each do |qualifier_name|
    qualifier = FoodQualifier.find_by!(qualifier_name: qualifier_name)

    # Only add if not already associated
    unless food.includes_qualifier?(qualifier)
      food.food_qualifiers << qualifier
    end
  end
end

puts "Foods with qualifiers created successfully!"
