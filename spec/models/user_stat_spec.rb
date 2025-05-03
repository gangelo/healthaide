require 'rails_helper'

RSpec.describe UserStat, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { create(:user_stat) }

    it { is_expected.to validate_uniqueness_of(:user_id) }
    it { is_expected.to allow_value('M').for(:sex) }
    it { is_expected.to allow_value('F').for(:sex) }
    it { is_expected.not_to allow_value('X').for(:sex) }

    it { is_expected.to validate_numericality_of(:height).is_greater_than_or_equal_to(48).is_less_than_or_equal_to(96).allow_nil }
    it { is_expected.to validate_numericality_of(:muscle_fat_analysis_weight).is_greater_than_or_equal_to(50.0).is_less_than_or_equal_to(500.0).allow_nil }
    it { is_expected.to validate_numericality_of(:obesity_analysis_percent_body_fat).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100).allow_nil }
  end
end
