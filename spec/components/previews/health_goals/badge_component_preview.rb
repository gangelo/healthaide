module HealthGoals
  class BadgeComponentPreview < ViewComponent::Preview
    def with_small_size
      render(HealthGoals::BadgeComponent.new(name: "Weight Loss", size: :sm))
    end

    def with_medium_size
      render(HealthGoals::BadgeComponent.new(name: "Reduce Blood Pressure", size: :md))
    end

    def with_full_size
      render(HealthGoals::BadgeComponent.new(name: "Improve Cardiovascular Health", size: :full))
    end
  end
end
