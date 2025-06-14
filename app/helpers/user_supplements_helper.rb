module UserSupplementsHelper
  def format_user_supplement(user_supplement)
    formatted_user_supplement = if user_supplement.supplement_components.any?
      "#{user_supplement.user_supplement_name} (#{format_supplement_components(user_supplement.supplement_components)})"
    elsif user_supplement.dosage?
      "#{user_supplement.user_supplement_name}, #{user_supplement.dosage} #{user_supplement.dosage_unit}"
    else
      "#{user_supplement.user_supplement_name}"
    end
    "#{formatted_user_supplement}, taken #{format_supplemet_component_frequency(user_supplement.frequency)}"
  end

  private

  def format_supplement_components(components)
    components.map { |sc| "#{sc.supplement_component_name} #{sc.amount} #{sc.unit}" }.join(", ")
  end

  def format_supplemet_component_frequency(frequency)
    frequency.to_s.humanize.downcase
  end
end
