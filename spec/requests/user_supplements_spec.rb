require 'rails_helper'

RSpec.describe "UserSupplements", type: :request do
  let(:user) { create(:user) }
  let(:user_supplement) { create(:user_supplement, user: user) }

  before do
    user.confirm
    sign_in user
  end

  describe "GET /index" do
    it "returns http success" do
      get user_supplements_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_user_supplement_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    let(:valid_attributes) {
      { user_supplement_name: "Test Supplement", form: "capsule", frequency: "daily" }
    }

    it "creates a new user supplement" do
      expect {
        post user_supplements_path, params: { user_supplement: valid_attributes }
      }.to change(UserSupplement, :count).by(1)

      expect(response).to redirect_to(user_supplement_path(UserSupplement.last))
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get edit_user_supplement_path(user_supplement)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    it "updates the user supplement" do
      patch user_supplement_path(user_supplement), params: {
        user_supplement: { user_supplement_name: "Updated Supplement" }
      }

      expect(response).to redirect_to(user_supplement_path(user_supplement))
      # The name_normalizable concern will normalize the name
      expect(user_supplement.reload.user_supplement_name).to eq("Updated supplement")
    end
  end

  describe "DELETE /destroy" do
    it "destroys the user supplement" do
      delete_supplement = create(:user_supplement, user: user)

      expect {
        delete user_supplement_path(delete_supplement)
      }.to change(UserSupplement, :count).by(-1)

      expect(response).to redirect_to(user_supplements_path)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get user_supplement_path(user_supplement)
      expect(response).to have_http_status(:success)
    end
  end
end
