module UserSupplementsHelper
  def format_user_supplement(supplement)
    formatted_user_supplement = if supplement.supplement_components.any?
      "#{supplement.user_supplement_name} (#{format_supplement_components(supplement.supplement_components)})"
    elsif supplement.dosage?
      "#{supplement.user_supplement_name}, #{supplement.dosage} #{supplement.dosage_unit}"
    else
      "#{supplement.user_supplement_name}"
    end
    "#{formatted_user_supplement}, taken #{format_supplemet_component_frequency(supplement.frequency)}"
  end

  private

  def format_supplement_components(components)
    components.map { |sc| "#{sc.supplement_component_name} #{sc.amount} #{sc.unit}" }.join(", ")
  end

  def format_supplemet_component_frequency(frequency)
    frequency.to_s.humanize.downcase
  end
end
