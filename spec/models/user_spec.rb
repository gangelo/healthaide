# frozen_string_literal: true

RSpec.describe User do
  subject(:user) { build(:user) }

  describe 'associations' do
    it { is_expected.to have_many(:user_foods).inverse_of(:user).dependent(:destroy) }
    it { is_expected.to have_many(:foods).through(:user_foods) }

    it { is_expected.to have_many(:user_health_conditions).inverse_of(:user).dependent(:destroy) }
    it { is_expected.to have_many(:health_conditions).through(:user_health_conditions).source(:health_condition) }

    it { is_expected.to have_many(:user_health_goals).inverse_of(:user).dependent(:destroy) }
    it { is_expected.to have_many(:health_goals).through(:user_health_goals) }

    it { is_expected.to have_one(:user_stat).inverse_of(:user).dependent(:destroy) }

    it { is_expected.to have_many(:user_supplements).inverse_of(:user).dependent(:destroy) }

    it { is_expected.to have_many(:user_medications).inverse_of(:user).dependent(:destroy) }
    it { is_expected.to have_many(:medications).through(:user_medications) }

    it { is_expected.to have_one(:user_meal_prompt).inverse_of(:user).dependent(:destroy) }
  end

  describe 'validations' do
    describe '#first_name' do
      it 'validates presence' do
        expect(user).to validate_presence_of(:first_name)
      end

      it 'validates the length' do
        expect(user).to validate_length_of(:first_name).is_at_most(64)
      end
    end

    describe '#last_name' do
      it 'validates presence' do
        expect(user).to validate_presence_of(:last_name)
      end

      it 'validates the length' do
        expect(user).to validate_length_of(:last_name).is_at_most(64)
      end
    end

    describe '#email' do
      it 'validates the length' do
        expect(user).to validate_length_of(:email).is_at_least(3).is_at_most(320)
      end

      it 'validates the uniqueness' do
        expect(user).to validate_uniqueness_of(:email).case_insensitive
      end
    end

    describe '#username' do
      it 'validates the length' do
        expect(user).to validate_length_of(:username).is_at_least(4).is_at_most(64)
      end

      it 'validates the uniqueness' do
        expect(user).to validate_uniqueness_of(:username).case_insensitive
      end
    end

    describe '#password' do
      it 'validates the length' do
        expect(user).to validate_length_of(:password).is_at_least(8).is_at_most(128)
      end
    end

    describe 'password complexity' do
      shared_examples 'the password complexity is validated' do
        let(:expected_error) do
          /Password must include at least one upper and lowercase letter, one number, and one special character/
        end

        it 'validates the password complexity' do
          expect(user.errors.full_messages).to include(expected_error)
        end
      end

      context 'when creating the user' do
        subject(:user) { build(:user, password: 'not complex') }

        before do
          user.save
        end

        it_behaves_like 'the password complexity is validated'
      end

      context 'when updating an existing user' do
        subject(:user) { create(:user) }

        before do
          user.password = 'not complex'
          user.save
        end

        it_behaves_like 'the password complexity is validated'
      end
    end
  end

  describe "#admin" do
    context "when the user is not an admin" do
      subject(:user) { build(:user) }

      it "returns false" do
        expect(user.admin?).to be false
      end
    end

    context "when the user is an admin" do
      subject(:user) { build(:user, :admin) }

      it "returns true" do
        expect(user.admin?).to be true
      end
    end
  end

  describe 'callbacks' do
    describe 'before_save' do
      subject(:user) { build(:user, email: email) }

      let(:email) { 'UPCASE.EMAIL@SOMEWHERE.COM' }

      it 'downcases the email' do
        expect { user.save }.to change(user, :email).from(email).to(email.downcase)
      end
    end
  end

  describe 'class methods' do
    describe '.find_for_database_authentication' do
      subject(:user) { create(:user, username: username, email: email) }

      before do
        user
      end

      let(:username) { 'testuser' }
      let(:email) { 'test@example.com' }

      context "when searching by username using 'email_or_username: <username>'" do
        it 'returns the correct user when using :email_or_username' do
          found_user = described_class.find_for_database_authentication(email_or_username: username)
          expect(found_user).to eq(user)
        end
      end

      context "when searching by username using 'username: <username>'" do
        it 'returns the correct user' do
          found_user = described_class.find_for_database_authentication(username: username)
          expect(found_user).to eq(user)
        end
      end

      context "when searching case-insensitive by username using 'email_or_username: <username>'" do
        it 'returns the correct user' do
          found_user = described_class.find_for_database_authentication(email_or_username: username.upcase)
          expect(found_user).to eq(user)
        end
      end

      context "when searching case-insensitive by username using 'username: <username>'" do
        it 'returns the correct user when using :username' do
          found_user = described_class.find_for_database_authentication(username: username.upcase)
          expect(found_user).to eq(user)
        end
      end

      context "when searching by email using 'email_or_username: <email>'" do
        it 'returns the correct user' do
          found_user = described_class.find_for_database_authentication(email_or_username: email)
          expect(found_user).to eq(user)
        end
      end

      context "when searching by email using 'email: <email>'" do
        it 'returns the correct user' do
          found_user = described_class.find_for_database_authentication(email: email)
          expect(found_user).to eq(user)
        end
      end

      context "when searching case-insensitive by email using 'email_or_username: <email>'" do
        it 'returns the correct user' do
          found_user = described_class.find_for_database_authentication(email_or_username: email.upcase)
          expect(found_user).to eq(user)
        end
      end

      context "when searching case-insensitive by email using 'email: <email>'" do
        it 'returns the correct user when using :email' do
          found_user = described_class.find_for_database_authentication(email: email.upcase)
          expect(found_user).to be_nil
        end
      end

      context "when searching username using 'email_or_username: <username>' with invalid username" do
        it 'returns nil' do
          found_user = described_class.find_for_database_authentication(email_or_username: 'nonexistent')
          expect(found_user).to be_nil
        end
      end

      context "when searching email using 'email: <email>' with invalid email" do
        it 'returns nil' do
          found_user = described_class.find_for_database_authentication(email: 'wrong@example.com')
          expect(found_user).to be_nil
        end
      end

      context "when searching username using 'username: <username>' with invalid username" do
        it 'returns nil' do
          found_user = described_class.find_for_database_authentication(username: 'nonexistent')
          expect(found_user).to be_nil
        end
      end
    end
  end
end
