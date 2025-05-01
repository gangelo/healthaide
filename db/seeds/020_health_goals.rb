puts "Creating health goals..."

health_goal_names = [
  "Cardiovascular health",
  "Balance blood sugar",
  "Balance electrolytes",
  "Balance hormones",
  "Boost cognitive function",
  "Boost energy levels",
  "Boost metabolism",
  "Enhance brain function",
  "Enhance gut health",
  "Enhance respiratory health",
  "Enhance skin health",
  "Improve athletic performance",
  "Improve cardiovascular endurance",
  "Improve digestion",
  "Improve mental clarity",
  "Improve sleep quality",
  "Increase muscle mass",
  "Increase muscle strength",
  "Lower cholesterol levels",
  "Lower triglyceride levels",
  "Maintain healthy blood pressure",
  "Maintain healthy weight",
  "Maintain muscle mass",
  "Optimize nutrient absorption",
  "Promote healthy aging",
  "Reduce allergic reactions",
  "Reduce inflammation",
  "Reduce stress levels",
  "Strengthen immune system",
  "Support bone health",
  "Support dental health",
  "Support heart health",
  "Support joint health",
  "Support kidney function",
  "Support liver function",
  "Support thyroid function"
]

health_goal_attributes = health_goal_names.map do |name|
  { health_goal_name: name }
end

HealthGoal.upsert_all(
  health_goal_attributes,
  unique_by: :health_goal_name,    # The unique constraint
  update_only: [ :health_goal_name ] # Fields to update if record exists
)
