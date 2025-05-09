class HealthConditionDecorator < BaseDecorator
  def formatted_name
    health_condition_name
  end

  def badge_class
    "inline-flex items-center px-3 py-0.5 rounded-full text-sm font-medium bg-blue-100 text-blue-800"
  end

  def badge_with_count(count = nil)
    if count
      "#{health_condition_name} (#{count})"
    else
      health_condition_name
    end
  end

  def summary_with_supplements(supplements)
    return health_condition_name if supplements.empty?

    supplement_names = supplements.map(&:user_supplement_name).join(", ")
    "#{health_condition_name} - Supplements: #{supplement_names}"
  end
end
