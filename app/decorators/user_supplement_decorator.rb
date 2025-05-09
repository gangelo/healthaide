class UserSupplementDecorator < BaseDecorator
  def formatted_dosage
    return "Not specified" unless dosage.present?
    "#{dosage} #{dosage_unit}"
  end

  def formatted_form
    form.to_s.humanize
  end

  def formatted_frequency
    frequency.to_s.humanize
  end

  def formatted_frequency_lowercase
    frequency.to_s.humanize.downcase
  end

  def formatted_manufacturer
    manufacturer.present? ? manufacturer : "Not specified"
  end

  def formatted_notes
    notes.present? ? notes : "No notes provided"
  end

  def component_count
    "#{supplement_components.count} #{supplement_components.count == 1 ? "component" : "components"}"
  end

  def supplement_info
    info = formatted_form
    info += " (#{formatted_dosage})" if dosage.present?
    info += ", taken #{formatted_frequency_lowercase}"
    info
  end

  def health_conditions_present?
    health_conditions.any?
  end

  def health_goals_present?
    health_goals.any?
  end
end
