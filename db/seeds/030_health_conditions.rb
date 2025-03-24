puts "Creating health conditions..."

HEALTH_CONDITIONS = [
  "Acid reflux",
  "Acne",
  "Addiction recovery",
  "Adrenal fatigue",
  "Age-related macular degeneration",
  "Alcoholism",
  "Allergies",
  "Alopecia",
  "Alzheimer's disease",
  "Anemia",
  "Angina",
  "Ankylosing spondylitis",
  "Anxiety",
  "Arrhythmia",
  "Arterial stiffness",
  "Arthritis",
  "Asthma",
  "Atherosclerosis",
  "Attention deficit hyperactivity disorder (adhd)",
  "Autism spectrum disorders",
  "Autoimmune disorders",
  "Benign prostatic hyperplasia",
  "Bipolar disorder",
  "Bloating",
  "Bone density loss",
  "Bursitis",
  "Cancer prevention",
  "Carpal tunnel syndrome",
  "Cataracts",
  "Celiac disease",
  "Chronic bronchitis",
  "Chronic fatigue syndrome",
  "Chronic kidney disease",
  "Chronic obstructive pulmonary disease",
  "Chronic pain",
  "Cirrhosis",
  "Cognitive decline",
  "Congestive heart failure",
  "Constipation",
  "Coronary artery disease",
  "Crohn's disease",
  "Cystic fibrosis",
  "Dementia",
  "Depression",
  "Dermatitis",
  "Diabetes type 1",
  "Diabetes type 2",
  "Diarrhea",
  "Diverticulitis",
  "Dyslipidemia",
  "Eczema",
  "Edema",
  "Endometriosis",
  "Epilepsy",
  "Erectile dysfunction",
  "Fatty liver disease",
  "Fibrocystic breast disease",
  "Fibromyalgia",
  "Food sensitivities",
  "Gallbladder disease",
  "Gastritis",
  "Gastroesophageal reflux disease",
  "Glaucoma",
  "Gout",
  "Hashimoto's thyroiditis",
  "Headaches",
  "Heart disease",
  "Helicobacter pylori (h. pylori) infection",
  "Hemorrhoids",
  "Hepatitis",
  "Hiatal hernia",
  "High blood pressure",
  "High cholesterol",
  "Hormonal imbalances",
  "Hypertension",
  "Hyperthyroidism",
  "Hypoglycemia",
  "Hypothyroidism",
  "Impaired glucose tolerance",
  "Infertility",
  "Inflammatory bowel disease",
  "Insomnia",
  "Insulin resistance",
  "Interstitial cystitis",
  "Irritable bowel syndrome",
  "Joint pain",
  "Kidney stones",
  "Leaky gut syndrome",
  "Low energy levels",
  "Low testosterone",
  "Lupus",
  "Lyme disease",
  "Lymphedema",
  "Macular degeneration",
  "Metabolic syndrome",
  "Meniere's disease",
  "Menopause symptoms",
  "Migraines",
  "Multiple sclerosis",
  "Muscle weakness",
  "Muscular dystrophy",
  "Myasthenia gravis",
  "Neuropathy",
  "Obesity",
  "Obsessive-compulsive disorder",
  "Osteoarthritis",
  "Osteopenia",
  "Osteoporosis",
  "Pancreatitis",
  "Parkinson's disease",
  "Peptic ulcer disease",
  "Peripheral artery disease",
  "Polycystic ovary syndrome",
  "Poor digestion",
  "Poor sleep quality",
  "Post-traumatic stress disorder",
  "Prediabetes",
  "Premenstrual syndrome",
  "Prostate enlargement",
  "Psoriasis",
  "Raynaud's phenomenon",
  "Restless leg syndrome",
  "Rheumatoid arthritis",
  "Rosacea",
  "Sarcoidosis",
  "Schizophrenia",
  "Seasonal affective disorder",
  "Seizure disorders",
  "Sleep apnea",
  "Stress management",
  "Stroke recovery",
  "Temporomandibular joint disorder",
  "Tendonitis",
  "Ulcerative colitis",
  "Urinary incontinence",
  "Urinary tract infections",
  "Varicose veins",
  "Weight management"
].freeze

HEALTH_CONDITIONS.each do |health_condition_name|
  HealthCondition.find_or_create_by!(health_condition_name: health_condition_name)
end
