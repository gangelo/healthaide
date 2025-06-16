RSpec.describe Ai::Provider do
  describe "constants" do
    it "defines provider constants" do
      expect(described_class::AI_PROVIDER_NONE).to eq("no_provider")
      expect(described_class::AI_PROVIDER_ANTHROPIC).to eq("anthropic")
      expect(described_class::AI_PROVIDER_DEEPSEEK).to eq("deepseek")
      expect(described_class::AI_PROVIDER_GEMINI).to eq("gemini")
      expect(described_class::AI_PROVIDER_OPENAI).to eq("openai")
    end

    it "defines ALL_AI_PROVIDERS" do
      expected_providers = [
        described_class::AI_PROVIDER_NONE,
        described_class::AI_PROVIDER_ANTHROPIC,
        described_class::AI_PROVIDER_DEEPSEEK,
        described_class::AI_PROVIDER_GEMINI,
        described_class::AI_PROVIDER_OPENAI
      ]
      expect(described_class::ALL_AI_PROVIDERS).to eq(expected_providers)
    end

    it "has models defined for all providers including none" do
      all_providers_with_none = described_class::ALL_AI_PROVIDERS + [ described_class::AI_PROVIDER_NONE ]

      all_providers_with_none.each do |provider|
        expect(described_class::AI_PROVIDER_MODELS).to have_key(provider)
        expect(described_class::AI_PROVIDER_MODELS[provider]).to be_an(Array)
        expect(described_class::AI_PROVIDER_MODELS[provider]).not_to be_empty
      end
    end
  end

  describe ".valid_provider?" do
    it "returns true for valid providers" do
      described_class::ALL_AI_PROVIDERS.each do |provider|
        expect(described_class.valid_provider?(provider)).to be true
      end
    end

    it "returns false for invalid providers" do
      expect(described_class.valid_provider?("invalid_provider")).to be false
      expect(described_class.valid_provider?(nil)).to be false
      expect(described_class.valid_provider?("")).to be false
    end
  end

  describe ".models_for" do
    context "with valid providers" do
      it "returns hash of models for anthropic" do
        models = described_class.models_for(described_class::AI_PROVIDER_ANTHROPIC)

        expect(models).to be_a(Hash)
        expect(models.keys).to include("claude-opus-4-20250514")
        expect(models.keys).to include("claude-sonnet-4-20250514")
        expect(models.keys).to include("claude-3-5-haiku-20241022")
        expect(models["claude-opus-4-20250514"]).to include("Premium flagship model")
      end

      it "returns hash of models for openai" do
        models = described_class.models_for(described_class::AI_PROVIDER_OPENAI)

        expect(models).to be_a(Hash)
        expect(models.keys).to include("gpt-4.1-2025-04-14")
        expect(models.keys).to include("gpt-4.1-nano")
        expect(models.keys).to include("o3")
        expect(models["o3"]).to include("Specialized reasoning model")
      end

      it "returns hash of models for gemini" do
        models = described_class.models_for(described_class::AI_PROVIDER_GEMINI)

        expect(models).to be_a(Hash)
        expect(models.keys).to include("gemini-2.5-pro-preview-06-05")
        expect(models.keys).to include("gemini-2.5-flash-preview-05-20")
        expect(models.keys).to include("gemini-2.0-flash-lite")
      end

      it "returns hash of models for deepseek" do
        models = described_class.models_for(described_class::AI_PROVIDER_DEEPSEEK)

        expect(models).to be_a(Hash)
        expect(models.keys).to include("deepseek-reasoner")
        expect(models.keys).to include("deepseek-chat")
        expect(models["deepseek-reasoner"]).to include("Advanced reasoning model")
      end
    end

    context "with AI_PROVIDER_NONE" do
      it "returns a dummy, placeholder model" do
        models = described_class.models_for(described_class::AI_PROVIDER_NONE)
        expect(models).to eq({ described_class::AI_PROVIDER_NONE => "No AI provider" })
      end
    end

    context "with invalid providers" do
      it "returns empty hash for invalid provider" do
        expect(described_class.models_for("invalid_provider")).to eq({})
        expect(described_class.models_for(nil)).to eq({})
        expect(described_class.models_for("")).to eq({})
      end
    end

    it "transforms model data structure correctly" do
      models = described_class.models_for(described_class::AI_PROVIDER_ANTHROPIC)

      # Verify the transformation from array of hashes to hash
      expect(models).to be_a(Hash)
      models.each do |model_name, notes|
        expect(model_name).to be_a(String)
        expect(notes).to be_a(String)
        expect(model_name).not_to be_empty
        expect(notes).not_to be_empty
      end
    end
  end



  describe "data integrity" do
    it "ensures all model entries have required keys" do
      described_class::AI_PROVIDER_MODELS.each do |provider, models|
        models.each do |model_data|
          expect(model_data).to have_key(:model)
          expect(model_data).to have_key(:notes)
          expect(model_data[:model]).to be_a(String)
          expect(model_data[:notes]).to be_a(String)
        end
      end
    end

    it "has unique model names within each provider" do
      described_class::AI_PROVIDER_MODELS.each do |provider, models|
        model_names = models.map { |m| m[:model] }
        expect(model_names).to eq(model_names.uniq),
          "Provider #{provider} has duplicate model names"
      end
    end

    it "has non-empty notes for all models" do
      described_class::AI_PROVIDER_MODELS.each do |provider, models|
        models.each do |model_data|
          expect(model_data[:notes].strip).not_to be_empty,
            "Model #{model_data[:model]} in #{provider} has empty notes"
        end
      end
    end
  end
end
