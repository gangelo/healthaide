describe Medications::Rxnorm::SearchService do
  shared_examples "a Medication::SharedResults object is returned" do
    it "returns a Medication::SharedResults object" do
      expect(described_class.search(term)).to be_kind_of(Medications::SearchResults)
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
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/approximateTerm.json?term=#{term}&maxEntries=100")
        .to_return(
          status: 200,
          body: file_fixture('medications_search_service_lexapro.json').read,
          headers: { 'Content-Type' => 'application/json' }
        )
      end

      let(:term) { "lexapro" }

      it_behaves_like "a Medication::SharedResults object is returned"

      it "returns the medication names in an array" do
        results = described_class.search(term)
        expect(results.medication_names).to match([
          "Lexapro",
          "Lexapro Pill",
          "Lexapro Oral Product",
          "escitalopram Oral Tablet [Lexapro]",
          "Lexapro Oral Liquid Product",
          "escitalopram Oral Solution [Lexapro]",
          "escitalopram 10 MG [Lexapro]",
          "escitalopram 20 MG [Lexapro]",
          "escitalopram 5 MG [Lexapro]",
          "Lexapro 20 MG Oral Tablet",
          "Lexapro 5 MG Oral Tablet",
          "Lexapro 10 MG Oral Tablet",
          "Lexapro 20 MG Oral Tablet",
          "Lexapro 5 MG Oral Tablet",
          "Lexapro 10 MG Oral Tablet",
          "escitalopram 20 MG Oral Tablet [Lexapro]",
          "escitalopram 5 MG Oral Tablet [Lexapro]",
          "escitalopram 10 MG Oral Tablet [Lexapro]",
          "Lexapro 1 MG/ML Oral Solution",
          "escitalopram 1 MG/ML [Lexapro]",
          "ESCITALOPRAM OXALATE 10 mg ORAL TABLET [Lexapro]",
          "ESCITALOPRAM OXALATE 20 mg ORAL TABLET [Lexapro]",
          "ESCITALOPRAM OXALATE 5 mg ORAL TABLET [Lexapro]",
          "ESCITALOPRAM OXALATE 10 mg ORAL TABLET [LEXAPRO]",
          "escitalopram 1 MG/ML Oral Solution [Lexapro]",
          "Lexapro 5 MG in 5 mL Oral Solution",
          "ESCITALOPRAM OXALATE 10 mg ORAL TABLET, FILM COATED [Lexapro]",
          "ESCITALOPRAM OXALATE 20 mg ORAL TABLET, FILM COATED [Lexapro]",
          "ESCITALOPRAM OXALATE 5 mg ORAL TABLET, FILM COATED [Lexapro]",
          "ESCITALOPRAM OXALATE 5 mg ORAL TABLET, FILM COATED [LEXAPRO]",
          "ESCITALOPRAM OXALATE 10 mg ORAL TABLET, FILM COATED [LEXAPRO]",
          "ESCITALOPRAM OXALATE 10 mg ORAL TABLET, FILM COATED [Lexapro]",
          "ESCITALOPRAM OXALATE 20 mg ORAL TABLET, FILM COATED [Lexapro]",
          "Lexapro (as escitalopram oxalate) 10 MG Oral Tablet",
          "Lexapro (as escitalopram oxalate) 20 MG Oral Tablet",
          "Lexapro (as escitalopram oxalate) 5 MG Oral Tablet",
          "ESCITALOPRAM OXALATE 5 mg in 5 mL ORAL SOLUTION [Lexapro]",
          "Lexapro (as escitalopram oxalate) 5 MG per 5 ML Oral Solution",
          "MENTHOL 40 mg in 1 g / LIDOCAINE 40 mg in 1 g TOPICAL PATCH [LenzaPro Flex]"
        ])
      end
    end

  context "when the search term returns no results" do
      before do
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/approximateTerm.json?term=#{term}&maxEntries=100")
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
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/approximateTerm.json?term=#{term}&maxEntries=100")
          .to_raise(StandardError.new("Connection failed"))
      end

      it 'returns the error in the result object' do
        result = described_class.search(term)
        expect(result.error_message).to match(/Request failed: Connection failed/)
      end
    end

    context 'when a timeout occurs' do
      before do
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/approximateTerm.json?term=#{term}&maxEntries=100")
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
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/approximateTerm.json?term=#{term}&maxEntries=100")
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
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/approximateTerm.json?term=#{term}&maxEntries=100")
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
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/approximateTerm.json?term=#{term}&maxEntries=100")
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
