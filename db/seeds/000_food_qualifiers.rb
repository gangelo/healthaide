puts "Creating food qualifiers..."

FOOD_QUALIFIERS = [
  "75/25"
  "80/20",
  "90/10",
  "Breast",
  "Canned",
  "Canned, olive oil",
  "Canned, spring water",
  "Chopped"
  "Dairy-free",
  "Egg-free",
  "Fresh",
  "Frozen",
  "Gluten-free",
  "Ground",
  "Leg",
  "Non-gmo",
  "Organic",
  "Raw",
  "Roasted",
  "Salt-free",
  "Salted",
  "Seed oil-free",
  "Sliced",
  "Thigh",
  "Wild caught"
].freeze

FOOD_QUALIFIERS.each do |qualifier_name|
  FoodQualifier.find_or_create_by!(qualifier_name: qualifier_name)
end
