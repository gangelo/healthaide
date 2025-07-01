describe UserProfile do
  subject(:user_profile) { create(:user_profile) }

  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "enums" do
    it { should define_enum_for(:ai_provider) }

    it "defines all the providers" do
      expect(described_class.ai_providers.count).to eq(6)

      expected_ai_providers = {
        Ai::Provider::AI_PROVIDER_NONE      => 0,
        Ai::Provider::AI_PROVIDER_ANTHROPIC => 10,
        Ai::Provider::AI_PROVIDER_DEEPSEEK  => 20,
        Ai::Provider::AI_PROVIDER_GEMINI    => 30,
        Ai::Provider::AI_PROVIDER_OPENAI    => 40,
        "default"                           => Ai::Provider::AI_PROVIDER_NONE
      }
      expect(described_class.ai_providers).to match(expected_ai_providers)
    end
  end

  describe "validations" do
    describe "#ai_provider" do
      it "is valid with valid ai_provider" do
        user_profile = create(:user_profile, :anthropic)
        expect(user_profile).to be_valid
      end

      it "raises an error with an invalid ai_provider" do
        expect { user_profile.ai_provider = :invalid_provider }.to raise_error(ArgumentError)
      end

      it "accepts all valid providers" do
        Ai::Provider::ALL_AI_PROVIDERS.each do |trait|
          user_profile = create(:user_profile, trait.to_sym)
          expect(user_profile).to be_valid, "Expected #{trait} to be valid"
        end
      end
    end

    describe "#ai_provider_model" do
      context "when #ai_provider is not Ai::Provider::AI_PROVIDER_NONE" do
        subject(:user_profile) { create(:user_profile, :anthropic) }

        it { should validate_presence_of(:ai_provider_model) }
      end

      context "when #ai_provider is Ai::Provider::AI_PROVIDER_NONE" do
        subject(:user_profile) { create(:user_profile, :no_provider) }

        it { should_not validate_presence_of(:ai_provider_model) }
      end

      context "when the model is not a valid model for the ai provider" do
        it "fails validation" do
          user_profile = create(:user_profile, :anthropic)
          user_profile.ai_provider_model = "invalid-ai-provider-model"

          expect(user_profile).to be_invalid
          expect(user_profile.errors[:ai_provider_model]).to include("'invalid-ai-provider-model' is not a valid model for AI provider 'anthropic'")
        end
      end

      it "skips model validation when provider is 'no_provider'" do
        user_profile = create(:user_profile, :no_provider)
        expect(user_profile).to be_valid
      end
    end

    describe "#api_provider_api_key" do
      context "when #ai_provider is not Ai::Provider::AI_PROVIDER_NONE" do
        subject(:user_profile) { create(:user_profile, :anthropic) }

        it { should validate_presence_of(:ai_provider_api_key) }
      end

      context "when #ai_provider is Ai::Provider::AI_PROVIDER_NONE" do
        subject(:user_profile) { create(:user_profile, :no_provider) }

        it { should_not validate_presence_of(:ai_provider_api_key) }
      end
    end
  end

  describe "before_save" do
    context "when there is no ai provider" do
      subject(:user_profile) { create(:user_profile, :anthropic) }

      before do
        user_profile.ai_provider = Ai::Provider::AI_PROVIDER_NONE
      end

      it "nils out #ai_provider_api_key and #ai_provider_model" do
        expect { user_profile.save! }.to change(user_profile, :ai_provider_model).to(nil)
          .and change(user_profile, :ai_provider_api_key).to(nil)
      end
    end
  end

  describe "#no_provider!" do
    subject(:user_profile) { create(:user_profile, :openai) }

    it "sets #ai_provider, and sets #ai_provider_model and #ai_provider_api_key to nil" do
      expect { user_profile.no_provider! }
        .to change(user_profile, :ai_provider).to(Ai::Provider::AI_PROVIDER_NONE)
        .and change(user_profile, :ai_provider_model).to(nil)
        .and change(user_profile, :ai_provider_api_key).to(nil)
    end
  end

  # TODO: Move this to a separate test file for factories.
  describe "factory traits" do
    it "creates valid user profiles with each provider trait" do
      Ai::Provider::ALL_AI_PROVIDERS.each do |trait|
        user_profile = create(:user_profile, trait.to_sym)
        expect(user_profile).to be_valid, "Factory trait #{trait} should create valid user_profile"
      end
    end
  end
end
