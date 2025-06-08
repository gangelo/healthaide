module Medications
  module Rxnorm
    class SearchService
      BASE_URL = "https://rxnav.nlm.nih.gov/REST"

      class << self
        def search(name)
          raise ArgumentError, "Argument [name] cannot be blank" if name.blank?

          # Fixed: approximateTerm (not approximageTerm)
          url = "#{BASE_URL}/approximateTerm.json?term=#{CGI.escape(name)}&maxEntries=100"

          begin
            response = Net::HTTP.get_response(URI(url))
            return Medications::SearchResults.new(error_message: "API request failed with status #{response.code}") unless response.code == "200"

            medication_names = to_medication_name_array(JSON.parse(response.body))
            Medications::SearchResults.new(medication_names:)
          rescue => e
            Medications::SearchResults.new(error_message: "Request failed: #{e.message}")
          end
        end

        private

        def to_medication_name_array(response_hash, return_data: "name")
          # Fixed: correct path through the response structure
          approximate_group = response_hash.dig("approximateGroup", "candidate")
          return [] unless approximate_group

          # Handle both single candidate (hash) and multiple candidates (array)
          candidates = approximate_group.is_a?(Array) ? approximate_group : [ approximate_group ]

          # Extract the specified field from each candidate
          candidates.map { |candidate| candidate[return_data] }.compact
        end
      end
    end
  end
end
