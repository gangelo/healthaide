class FoodQualifierExportService
  class << self
    def export
      FoodQualifier.select(:qualifier_name).ordered.pluck(:qualifier_name)
    end
  end
end
