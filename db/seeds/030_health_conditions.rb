puts "Creating health conditions..."

HealthCondition.find_or_create_by!(health_condition_name: "High cholesterol")
HealthCondition.find_or_create_by!(health_condition_name: "High blood pressure")
HealthCondition.find_or_create_by!(health_condition_name: "Helicobacter pylori (h. pylori) infection")
HealthCondition.find_or_create_by!(health_condition_name: "Low energy levels")
HealthCondition.find_or_create_by!(health_condition_name: "Poor sleep quality")
