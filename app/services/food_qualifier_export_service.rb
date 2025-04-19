class FoodQualifierExportService
  def self.export
    FoodQualifier.select(:qualifier_name).ordered.pluck(:qualifier_name)
  end
end
