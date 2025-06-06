describe Medications::Rxnorm::SearchService do
  describe ".search" do
    context "with a valid search term" do
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

      it "returns medication names for a valid search" do
        results = described_class.search(term)

        expect(results).to match([
          "escitalopram 10 MG Oral Tablet [Lexapro]",
          "escitalopram 20 MG Oral Tablet [Lexapro]",
          "escitalopram 5 MG Oral Tablet [Lexapro]"
        ])
      end
    end

    context "when a 4xx status is returned" do
      before do
        stub_request(:get, "https://rxnav.nlm.nih.gov/REST/drugs.json?name=#{term}")
          .to_return(
            status: 404,
            body: "Not Found"
          )
      end

      let(:term) { "whatever" }

      it "returns a hash with the error" do
        expected_error = "API request failed with status #{404}"

        expect(described_class.search(term)).to eq({ error: expected_error })
      end
    end
  end
end
