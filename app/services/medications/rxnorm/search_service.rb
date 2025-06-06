module Medications
  module Rxnorm
    class SearchService
      BASE_URL = "https://rxnav.nlm.nih.gov/REST"

      class << self
        def search(name)
          url = "#{BASE_URL}/drugs.json?name=#{CGI.escape(name)}"

          begin
            response = Net::HTTP.get_response(URI(url))
            return { error: "API request failed with status #{response.code}" } unless response.code == "200"

            to_medication_name_array(JSON.parse(response.body)) || []
          rescue => e
            { error: "Request failed: #{e.message}" }
          end
        end

        private

        def to_medication_name_array(response_hash)
          concept_group = response_hash.dig("drugGroup", "conceptGroup")&.find { |entry| entry.key?("conceptProperties") }
          concept_group.dig("conceptProperties").map { |entry| entry["name"] } if concept_group
        end
      end
    end
  end
end
