RSpec.describe Ai::ProviderChatService do
  subject(:service) { described_class.new(user) }

  let(:user)          { create(:user) }
  let(:mock_chat)    { instance_double('RubyLLM::Chat') }
  let(:mock_context) { instance_double('RubyLLM::Context') }
  let(:mock_config)  { double('config') }

  before do
    # Stub RubyLLM to trigger actual method calls in your service
    allow(RubyLLM).to      receive(:context).and_yield(mock_config).and_return(mock_context)
    allow(mock_context).to receive(:chat).and_return(mock_chat)
    allow(mock_config).to  receive(:public_send) # Allow any API key configuration
  end

  describe '#initialize' do
    context 'when user has an AI provider configured' do
      before do
        user.profile.update!(
          ai_provider: Ai::Provider::AI_PROVIDER_ANTHROPIC,
          ai_provider_model: first_model_for(Ai::Provider::AI_PROVIDER_ANTHROPIC),
          ai_provider_api_key: 'test-key'
        )
      end

      it 'initializes successfully' do
        expect { service }.not_to raise_error
      end
    end

    context 'when user does not have an AI provider configured' do
      before do
        user.profile.update!(ai_provider: Ai::Provider::AI_PROVIDER_NONE)
      end

      it 'raises ArgumentError' do
        expect { service }.to raise_error(ArgumentError, /is not a valid provider/)
      end
    end
  end

  describe '#ask' do
    before do
      user.profile.update!(
        ai_provider: Ai::Provider::AI_PROVIDER_ANTHROPIC,
        ai_provider_model: first_model_for(Ai::Provider::AI_PROVIDER_ANTHROPIC),
        ai_provider_api_key: 'test-key'
      )
    end

    it 'delegates to chat' do
      expect(mock_chat).to receive(:ask).with('What is Ruby?')
      service.ask('What is Ruby?')
    end
  end

  describe '#with_instructions' do
    before do
      user.profile.update!(
        ai_provider: Ai::Provider::AI_PROVIDER_ANTHROPIC,
        ai_provider_model: first_model_for(Ai::Provider::AI_PROVIDER_ANTHROPIC),
        ai_provider_api_key: 'test-key'
      )
    end

    it 'delegates to chat' do
      expect(mock_chat).to receive(:with_instructions).with('Be helpful', replace: true)
      service.with_instructions('Be helpful', replace: true)
    end
  end

  describe '#history' do
    before do
      user.profile.update!(
        ai_provider: Ai::Provider::AI_PROVIDER_ANTHROPIC,
        ai_provider_model: first_model_for(Ai::Provider::AI_PROVIDER_ANTHROPIC),
        ai_provider_api_key: 'test-key'
      )
    end

    let(:mock_messages) do
      [
        instance_double('RubyLLM::Message', role: :user, content: 'Hello'),
        instance_double('RubyLLM::Message', role: :assistant, content: 'Hi there!')
      ]
    end

    before do
      allow(mock_chat).to receive(:messages).and_return(mock_messages)
    end

    it 'returns chat history as array of hashes' do
      expected_history = [
        { role: :user, content: 'Hello' },
        { role: :assistant, content: 'Hi there!' }
      ]

      expect(service.history).to eq(expected_history)
    end
  end

  private

  def first_model_for(provider)
    Ai::Provider.models_for(provider).keys.first
  end
end
