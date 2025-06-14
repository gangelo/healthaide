
RSpec.describe SupplementComponent, type: :model do
  describe "validations" do
    it { should validate_presence_of(:supplement_component_name) }
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:unit) }
  end

  describe "associations" do
    it { should belong_to(:user_supplement) }
  end

  describe "#to_export_hash" do
    it "returns a hash with the component's attributes" do
      component = create(:supplement_component)

      export_hash = component.to_export_hash

      expect(export_hash).to be_a(Hash)
      expect(export_hash[:supplement_component]).to include(
        supplement_component_name: component.supplement_component_name,
        amount: component.amount,
        unit: component.unit
      )
    end
  end
end
