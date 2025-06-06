describe Medications::Rxnorm::SearchService do
  shared_examples "a Medication::SharedResults object is returned" do
    it "returns a Medication::SharedResults object" do
      expect(described_class.search(term)).to be_kind_of(Medication::SearchResults)
    end
  end

  describe ".search" do
     context "when the search term is blank" do
      it "raises an error" do
        expect { described_class.search(nil) }.to raise_error("Argument [name] cannot be blank")
      end
    end

    context "when the search term returns results" do
      before do
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/drugs.json?name=#{term}")
        .to_return(
          status: 200,
          body: {
            "drugGroup": {
              "name": nil,
              "conceptGroup": [
                {
                  "tty": "BPCK"
                },
                {
                  "tty": "SBD",
                  "conceptProperties": [
                    {
                      "rxcui": "352272",
                      "name": "escitalopram 10 MG Oral Tablet [Lexapro]",
                      "synonym": "Lexapro 10 MG Oral Tablet",
                      "tty": "SBD",
                      "language": "ENG",
                      "suppress": "N",
                      "umlscui": ""
                    },
                    {
                      "rxcui": "352273",
                      "name": "escitalopram 20 MG Oral Tablet [Lexapro]",
                      "synonym": "Lexapro 20 MG Oral Tablet",
                      "tty": "SBD",
                      "language": "ENG",
                      "suppress": "N",
                      "umlscui": ""
                    },
                    {
                      "rxcui": "404408",
                      "name": "escitalopram 5 MG Oral Tablet [Lexapro]",
                      "synonym": "Lexapro 5 MG Oral Tablet",
                      "tty": "SBD",
                      "language": "ENG",
                      "suppress": "N",
                      "umlscui": ""
                    }
                  ]
                }
              ]
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      end

      let(:term) { "lexapro" }

      it_behaves_like "a Medication::SharedResults object is returned"

      it "returns the medication names in an array" do
        results = described_class.search(term)
        expect(results.medication_names).to match([
          "escitalopram 10 MG Oral Tablet [Lexapro]",
          "escitalopram 20 MG Oral Tablet [Lexapro]",
          "escitalopram 5 MG Oral Tablet [Lexapro]"
        ])
      end
    end

  context "when the search term returns no results" do
      before do
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/drugs.json?name=#{term}")
        .to_return(
          status: 200,
          body: {
            "drugGroup": {
              "name": nil
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      end

      let(:term) { "lexapro" }

      it_behaves_like "a Medication::SharedResults object is returned"

      it "returns an empty array" do
        results = described_class.search(term)
        expect(results.medication_names).to eq([])
      end
    end

    context 'when a network error occurs' do
      let(:term) { 'connection_error' }

      before do
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/drugs.json?name=#{term}")
          .to_raise(StandardError.new("Connection failed"))
      end

      it 'returns the error in the result object' do
        result = described_class.search(term)
        expect(result.error_message).to match(/Request failed: Connection failed/)
      end
    end

    context 'when a timeout occurs' do
      before do
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/drugs.json?name=#{term}")
          .to_timeout
      end

      let(:term) { 'timeout_test' }

      it_behaves_like "a Medication::SharedResults object is returned"

      it 'returns a hash with timeout error' do
        result = described_class.search(term)
        expect(result.error_message).to include("Request failed")
      end
    end

    context 'when connection is refused' do
      before do
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/drugs.json?name=#{term}")
          .to_raise(Errno::ECONNREFUSED)
      end

      let(:term) { 'refused_connection' }

      it_behaves_like "a Medication::SharedResults object is returned"

      it 'returns a hash with connection error' do
        result = described_class.search(term)
        expect(result.error_message).to match(/Request failed: Connection refused/)
      end
    end

    context 'when API returns 500 error' do
      before do
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/drugs.json?name=#{term}")
          .to_return(status: 500, body: "Internal Server Error")
      end

      let(:term) { 'server_error' }

      it_behaves_like "a Medication::SharedResults object is returned"

      it 'returns a hash with API error' do
        result = described_class.search(term)
        expect(result.error_message).to eq("API request failed with status 500")
      end
    end

    context 'when API returns 404 error' do
      before do
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/drugs.json?name=#{term}")
          .to_return(status: 404, body: "Not Found")
      end

      let(:term) { 'not_found' }

      it_behaves_like "a Medication::SharedResults object is returned"

      it 'returns a hash with not found error' do
        result = described_class.search(term)
        expect(result.error_message).to eq("API request failed with status 404")
      end
    end
  end
end
