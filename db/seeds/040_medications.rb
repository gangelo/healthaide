puts "Creating medications..."

MEDICATIONS = [
  "10 ML morphine sulfate 0.5 MG/ML Injection [Duramorph]",
  "10 ML morphine sulfate 1 MG/ML Injection [Duramorph]",
  "20 ML morphine sulfate 10 MG/ML Injection [Infumorph]",
  "20 ML morphine sulfate 10 MG/ML Injection [Mitigo]",
  "20 ML morphine sulfate 25 MG/ML Injection [Infumorph]",
  "20 ML morphine sulfate 25 MG/ML Injection [Mitigo]",
  "Abuse-Deterrent 12 HR morphine sulfate 15 MG Extended Release Oral Tablet [Arymo]",
  "Abuse-Deterrent 12 HR morphine sulfate 30 MG Extended Release Oral Tablet [Arymo]",
  "Abuse-Deterrent 12 HR morphine sulfate 60 MG Extended Release Oral Tablet [Arymo]",
  "diazepam 10 MG Oral Tablet [Valium]",
  "diazepam 2 MG Oral Tablet [Valium]",
  "diazepam 5 MG Oral Tablet [Valium]",
  "escitalopram 10 MG Oral Tablet [Lexapro]",
  "escitalopram 20 MG Oral Tablet [Lexapro]",
  "escitalopram 5 MG Oral Tablet [Lexapro]",
  "esomeprazole 10 MG Granules for Oral Suspension [Nexium]",
  "esomeprazole 2.5 MG Granules for Oral Suspension [Nexium]",
  "esomeprazole 20 MG Delayed Release Oral Capsule [Nexium]",
  "esomeprazole 20 MG Delayed Release Oral Tablet [Nexium]",
  "esomeprazole 20 MG Granules for Oral Suspension [Nexium]",
  "esomeprazole 40 MG Delayed Release Oral Capsule [Nexium]",
  "esomeprazole 40 MG Granules for Oral Suspension [Nexium]",
  "esomeprazole 40 MG Injection [Nexium]",
  "esomeprazole 5 MG Granules for Oral Suspension [Nexium]",
  "morphine sulfate 10 MG Extended Release Oral Capsule [Kadian]",
  "morphine sulfate 100 MG Extended Release Oral Capsule [Kadian]",
  "morphine sulfate 100 MG Extended Release Oral Tablet [MS Contin]",
  "morphine sulfate 15 MG Extended Release Oral Tablet [MS Contin]",
  "morphine sulfate 20 MG Extended Release Oral Capsule [Kadian]",
  "morphine sulfate 200 MG Extended Release Oral Tablet [MS Contin]",
  "morphine sulfate 30 MG Extended Release Oral Capsule [Kadian]",
  "morphine sulfate 30 MG Extended Release Oral Tablet [MS Contin]",
  "morphine sulfate 50 MG Extended Release Oral Capsule [Kadian]",
  "morphine sulfate 60 MG Extended Release Oral Capsule [Kadian]",
  "morphine sulfate 60 MG Extended Release Oral Tablet [MS Contin]"
]

MEDICATIONS.each do |medication_name|
  Medication.find_or_create_by!(medication_name: medication_name)
end

puts "Medications created successfully!"
