puts "Creating food qualifiers..."

FOOD_QUALIFIERS = [
  "Breast",
  "Canned",
  "Canned, olive oil",
  "Canned, spring water",
  "Dairy-free",
  "Egg-free",
  "Fresh",
  "Frozen",
  "Gluten-free",
  "Leg",
  "Non-gmo",
  "Organic",
  "Raw",
  "Seed oil-free",
  "Sliced",
  "Thigh",
  "Wild caught"
].freeze

FOOD_QUALIFIERS.each do |qualifier_name|
  FoodQualifier.find_or_create_by!(qualifier_name: qualifier_name)
end
