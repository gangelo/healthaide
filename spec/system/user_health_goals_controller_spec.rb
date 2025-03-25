require 'rails_helper'

RSpec.describe UserHealthGoalsController, type: :controller do
  let(:user) { create(:user) }
  let(:health_goal) { create(:health_goal) }

  before do
    user.confirm
    sign_in user
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "assigns @user_health_goals ordered by importance" do
      high_priority = create(:user_health_goal, order_of_importance: 10, user: user)
      medium_priority = create(:user_health_goal, order_of_importance: 5, user: user)
      low_priority = create(:user_health_goal, order_of_importance: 1, user: user)

      get :index

      expect(assigns(:user_health_goals)).to eq([ low_priority, medium_priority, high_priority ])
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end

    it "assigns a new user_health_goal" do
      get :new
      expect(assigns(:user_health_goal)).to be_a_new(UserHealthGoal)
    end
  end

  describe "POST #create" do
    context "with existing health goal" do
      it "creates a new user_health_goal with default importance" do
        expect {
          post :create, params: {
            user_health_goal: {
              health_goal_id: health_goal.id,
              order_of_importance: '5'
            }
          }
        }.to change(UserHealthGoal, :count).by(1)

        expect(UserHealthGoal.last.order_of_importance).to eq(5)
        expect(response).to redirect_to(user_health_goals_path)
      end
    end

    context "with new health goal" do
      it "creates a new health goal and user_health_goal with default importance" do
        expect {
          post :create, params: {
            user_health_goal: {
              health_goal_name: 'New Health Goal',
              order_of_importance: '5'
            }
          }
        }.to change(UserHealthGoal, :count).by(1)
         .and change(HealthGoal, :count).by(1)

        expect(UserHealthGoal.last.order_of_importance).to eq(5)
        expect(HealthGoal.last.health_goal_name).to eq('New Health Goal')
        expect(response).to redirect_to(user_health_goals_path)
      end
    end
  end

  describe "GET #select_multiple" do
    before do
      create_list(:health_goal, 5)
    end

    it "returns http success" do
      get :select_multiple
      expect(response).to have_http_status(:success)
    end

    it "filters health goals based on search term" do
      create(:health_goal, health_goal_name: "Weight Loss")
      create(:health_goal, health_goal_name: "Muscle Gain")

      get :select_multiple, params: { search: "weight" }

      expect(assigns(:health_goals).map(&:health_goal_name)).to include("Weight Loss")
      expect(assigns(:health_goals).map(&:health_goal_name)).not_to include("Muscle Gain")
    end

    it "renders the goals list frame for turbo frame requests" do
      get :select_multiple, params: { frame_id: "goals_list" }, headers: { "Turbo-Frame" => "goals_list" }

      expect(response).to render_template(:_goals_list_frame)
    end
  end

  describe "POST #add_multiple" do
    let!(:health_goals) { create_list(:health_goal, 3) }

    it "adds multiple health goals with incremental importance" do
      expect {
        post :add_multiple, params: { health_goal_ids: health_goals.map(&:id) }
      }.to change(UserHealthGoal, :count).by(3)

      user_health_goals = user.user_health_goals.order(:order_of_importance)
      expect(user_health_goals.map(&:order_of_importance)).to eq([ 1, 2, 3 ])
    end

    it "handles duplicate health goals" do
      existing = create(:user_health_goal, user: user, health_goal: health_goals.first)

      expect {
        post :add_multiple, params: { health_goal_ids: health_goals.map(&:id) }
      }.to change(UserHealthGoal, :count).by(2)
    end

    it "returns an error when no health goals are selected" do
      post :add_multiple, params: { health_goal_ids: [] }

      expect(response).to redirect_to(user_health_goals_path)
      expect(flash[:alert]).to include("Please select at least one health goal")
    end
  end

  describe "PATCH #update_importance" do
    let!(:user_health_goal) { create(:user_health_goal, user: user, order_of_importance: 5) }

    before do
      create(:user_health_goal, user: user, order_of_importance: 1)
      create(:user_health_goal, user: user, order_of_importance: 2)
      create(:user_health_goal, user: user, order_of_importance: 3)
      create(:user_health_goal, user: user, order_of_importance: 4)
      create(:user_health_goal, user: user, order_of_importance: 6)
      create(:user_health_goal, user: user, order_of_importance: 7)
    end

    it "updates importance and reorders other goals (moving up)" do
      patch :update_importance, params: { id: user_health_goal.id, order_of_importance: 2 }

      expect(response).to have_http_status(:success)

      user_health_goal.reload
      expect(user_health_goal.order_of_importance).to eq(2)

      # Check that other goals were shifted
      goals = user.user_health_goals.order(:order_of_importance)
      expect(goals.map(&:order_of_importance)).to eq([ 1, 2, 3, 4, 5, 6, 7 ])
    end

    it "updates importance and reorders other goals (moving down)" do
      patch :update_importance, params: { id: user_health_goal.id, order_of_importance: 7 }

      expect(response).to have_http_status(:success)

      user_health_goal.reload
      expect(user_health_goal.order_of_importance).to eq(7)

      # Check that other goals were shifted
      goals = user.user_health_goals.order(:order_of_importance)
      expect(goals.map(&:order_of_importance)).to eq([ 1, 2, 3, 4, 5, 6, 7 ])
    end
  end
end
