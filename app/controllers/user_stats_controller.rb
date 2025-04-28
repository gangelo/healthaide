class UserStatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_stat, only: %i[ show edit update destroy ]

  # GET /user_stats
  def index
    @user_stat = current_user.user_stat
    if @user_stat
      redirect_to edit_user_stat_path(@user_stat)
    else
      redirect_to new_user_stat_path
    end
  end

  # GET /user_stats/1
  def show
    if @user_stat
      redirect_to edit_user_stat_path(@user_stat)
    else
      redirect_to new_user_stat_path
    end
  end

  # GET /user_stats/new
  def new
    # If user already has stats, redirect to edit
    if current_user.user_stat.present?
      redirect_to edit_user_stat_path(current_user.user_stat)
      return
    end

    @user_stat = UserStat.new(user: current_user)
  end

  # GET /user_stats/1/edit
  def edit
  end

  # POST /user_stats
  def create
    @user_stat = UserStat.new(user_stat_params)
    @user_stat.user = current_user

    if @user_stat.save
      redirect_to edit_user_stat_path(@user_stat), notice: "Your stats were successfully saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /user_stats/1
  def update
    if @user_stat.update(user_stat_params)
      redirect_to edit_user_stat_path(@user_stat), notice: "Your stats were successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /user_stats/1
  def destroy
    @user_stat.destroy
    redirect_to new_user_stat_path, notice: "Your stats were successfully deleted."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_stat
      @user_stat = current_user.user_stat
      redirect_to new_user_stat_path if @user_stat.nil?
    end

    # Only allow a list of trusted parameters through.
    def user_stat_params
      params.require(:user_stat).permit(
        :birthday,
        :sex,
        :height,
        :muscle_fat_analysis_weight,
        :muscle_fat_analysis_skeletal_muscle_mass,
        :muscle_fat_analysis_body_fat_mass,
        :muscle_fat_analysis_cid,
        :obesity_analysis_bmi,
        :obesity_analysis_percent_body_fat,
        :abdominal_obesity_analysis_waist_hip_ratio,
        :abdominal_obesity_analysis_visceral_fat_level,
        :comprehensive_analysis_basal_metabolic_rate,
        :body_balance_evaluation_upper_lower,
        :body_composition_analysis_soft_lean_mass
      )
    end
end
