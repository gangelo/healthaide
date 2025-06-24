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

    it "freezes ALL_AI_PROVIDERS" do
      expect(described_class::ALL_AI_PROVIDERS).to be_frozen
    end
  end

  describe ".valid_provider?" do
    context "with valid providers" do
      it "returns true for all defined providers" do
        described_class::ALL_AI_PROVIDERS.each do |provider|
          expect(described_class.valid_provider?(provider)).to be true
        end
      end
    end

    context "with invalid providers" do
      it "returns false for invalid providers" do
        expect(described_class.valid_provider?("invalid_provider")).to be false
        expect(described_class.valid_provider?("random_string")).to be false
        expect(described_class.valid_provider?("")).to be false
      end

      it "returns false for nil" do
        expect(described_class.valid_provider?(nil)).to be false
      end
    end
  end

  describe ".models_for" do
    context "with valid providers" do
      it "returns a hash for anthropic provider" do
        models = described_class.models_for(described_class::AI_PROVIDER_ANTHROPIC)

        expect(models).to be_a(Hash)
        # Should have models available through RubyLLM::Aliases
        unless models.empty?
          models.each do |model_name, provider_model_id|
            expect(model_name).to be_a(String)
            expect(provider_model_id).to be_a(String)
            expect(model_name).not_to be_empty
            expect(provider_model_id).not_to be_empty
          end
        end
      end

      it "returns a hash for openai provider" do
        models = described_class.models_for(described_class::AI_PROVIDER_OPENAI)

        expect(models).to be_a(Hash)
        unless models.empty?
          models.each do |model_name, provider_model_id|
            expect(model_name).to be_a(String)
            expect(provider_model_id).to be_a(String)
          end
        end
      end

      it "returns a hash for gemini provider" do
        models = described_class.models_for(described_class::AI_PROVIDER_GEMINI)

        expect(models).to be_a(Hash)
        unless models.empty?
          models.each do |model_name, provider_model_id|
            expect(model_name).to be_a(String)
            expect(provider_model_id).to be_a(String)
          end
        end
      end

      it "returns a hash for deepseek provider" do
        models = described_class.models_for(described_class::AI_PROVIDER_DEEPSEEK)

        expect(models).to be_a(Hash)
        unless models.empty?
          models.each do |model_name, provider_model_id|
            expect(model_name).to be_a(String)
            expect(provider_model_id).to be_a(String)
          end
        end
      end
    end

    context "with no_provider" do
      it "returns empty hash for no_provider" do
        models = described_class.models_for(described_class::AI_PROVIDER_NONE)
        expect(models).to eq({})
      end
    end

    context "with invalid providers" do
      it "returns empty hash for invalid provider" do
        expect(described_class.models_for("invalid_provider")).to eq({})
      end

      it "returns empty hash for nil" do
        expect(described_class.models_for(nil)).to eq({})
      end

      it "returns empty hash for empty string" do
        expect(described_class.models_for("")).to eq({})
      end
    end

    context "when RubyLLM::Aliases is available" do
      before do
        # Mock RubyLLM::Aliases to ensure consistent test behavior
        allow(RubyLLM::Aliases).to receive(:aliases).and_return({
          "claude-3-5-sonnet" => {
            "anthropic" => "claude-3-5-sonnet-20241022",
            "openrouter" => "anthropic/claude-3.5-sonnet"
          },
          "gpt-4" => {
            "openai" => "gpt-4-turbo",
            "openrouter" => "openai/gpt-4-turbo"
          },
          "gemini-pro" => {
            "gemini" => "gemini-1.5-pro",
            "openrouter" => "google/gemini-pro"
          }
        })
      end

      it "returns models correctly from RubyLLM::Aliases for anthropic" do
        models = described_class.models_for("anthropic")
        expect(models).to include("claude-3-5-sonnet" => "claude-3-5-sonnet-20241022")
      end

      it "returns models correctly from RubyLLM::Aliases for openai" do
        models = described_class.models_for("openai")
        expect(models).to include("gpt-4" => "gpt-4-turbo")
      end

      it "returns models correctly from RubyLLM::Aliases for gemini" do
        models = described_class.models_for("gemini")
        expect(models).to include("gemini-pro" => "gemini-1.5-pro")
      end
    end
  end

  describe ".all_models" do
    it "returns a hash with all providers" do
      all_models = described_class.all_models

      expect(all_models).to be_a(Hash)
      described_class::ALL_AI_PROVIDERS.each do |provider|
        expect(all_models).to have_key(provider)
        expect(all_models[provider]).to be_an(Array)
      end
    end

    it "includes models for each provider" do
      all_models = described_class.all_models

      all_models.each do |provider, models_array|
        expect(models_array).to be_an(Array)
        expect(models_array.length).to eq(1) # Each provider gets one hash of models
        expect(models_array.first).to be_a(Hash)
      end
    end
  end

  describe "integration with RubyLLM" do
    it "depends on RubyLLM::Aliases being available" do
      expect(defined?(RubyLLM::Aliases)).to be_truthy
      expect(RubyLLM::Aliases).to respond_to(:aliases)
    end

    it "handles RubyLLM::Aliases.aliases returning empty hash gracefully" do
      allow(RubyLLM::Aliases).to receive(:aliases).and_return({})

      described_class::ALL_AI_PROVIDERS.each do |provider|
        models = described_class.models_for(provider)
        expect(models).to eq({})
      end
    end
  end
end
