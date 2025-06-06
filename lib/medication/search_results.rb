module Medication
  class SearchResults
    attr_reader :medication_names, :error_message

    def initialize(medication_names: nil, error_message: nil)
      @medication_names = medication_names || []
      @error_message    = error_message
    end

    def success?
      error_message.blank?
    end
  end
end
