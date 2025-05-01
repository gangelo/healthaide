class UserSupplementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_supplement, only: [ :show, :edit, :update, :destroy, :add_component, :remove_component ]

  def index
    @user_supplements = current_user.user_supplements.with_associations.ordered
  end

  def show
  end

  def new
    @user_supplement = current_user.user_supplements.build
  end

  def edit
  end

  def create
    @user_supplement = current_user.user_supplements.build(user_supplement_params)

    respond_to do |format|
      if @user_supplement.save
        format.html { redirect_to user_supplement_path(@user_supplement), notice: "Supplement was successfully added." }
        format.turbo_stream do
          flash.now[:notice] = "Supplement was successfully added."
          render turbo_stream: [
            turbo_stream.update("main_content", partial: "user_supplements/list/list", locals: { user_supplements: current_user.user_supplements.ordered }),
            turbo_stream.update("flash_messages", partial: "shared/flash_messages")
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("main_content", partial: "user_supplements/form", locals: { user_supplement: @user_supplement })
        end
      end
    end
  end

  def update
    # Process health conditions and goals separately because accepts_nested_attributes_for
    # doesn't handle the removal of has_many through associations properly
    health_condition_ids = params[:user_supplement][:health_condition_ids]&.reject(&:blank?) || []
    health_goal_ids = params[:user_supplement][:health_goal_ids]&.reject(&:blank?) || []
    
    respond_to do |format|
      if @user_supplement.update(user_supplement_params)
        # Associate health conditions and goals - always call these to handle checkbox unchecking
        update_health_conditions(health_condition_ids)
        update_health_goals(health_goal_ids)
        
        @user_supplement.reload
        
        format.html { redirect_to edit_user_supplement_path(@user_supplement), notice: "Supplement was successfully updated." }
        format.turbo_stream do
          flash.now[:notice] = "Supplement was successfully updated."
          render turbo_stream: [
            turbo_stream.update("main_content", partial: "form", locals: { user_supplement: @user_supplement }),
            turbo_stream.update("flash_messages", partial: "shared/flash_messages")
          ]
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:alert] = "Unable to update supplement."
          render turbo_stream: turbo_stream.update("main_content", partial: "form", locals: { user_supplement: @user_supplement })
        end
      end
    end
  end

  def destroy
    @user_supplement.destroy

    respond_to do |format|
      format.html { redirect_to user_supplements_path, notice: "Supplement was successfully removed." }
      format.turbo_stream do
        flash.now[:notice] = "Supplement was successfully removed."
        render turbo_stream: [
          turbo_stream.update("main_content", partial: "user_supplements/list/list", locals: { user_supplements: current_user.user_supplements.ordered }),
          turbo_stream.update("flash_messages", partial: "shared/flash_messages")
        ]
      end
    end
  end

  def add_component
    @supplement_component = @user_supplement.supplement_components.build(component_params)

    respond_to do |format|
      if @supplement_component.save
        format.html { redirect_to user_supplement_path(@user_supplement), notice: "Component was successfully added." }
        format.turbo_stream do
          flash.now[:notice] = "Component was successfully added."
          render turbo_stream: [
            turbo_stream.update("components_list", partial: "user_supplements/components/list", locals: { user_supplement: @user_supplement }),
            turbo_stream.update("flash_messages", partial: "shared/flash_messages")
          ]
        end
      else
        format.html { render :show, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:alert] = "Unable to add component: #{@supplement_component.errors.full_messages.join(", ")}"
          render turbo_stream: [
            turbo_stream.update("components_list", partial: "user_supplements/components/list", locals: { user_supplement: @user_supplement }),
            turbo_stream.update("flash_messages", partial: "shared/flash_messages")
          ]
        end
      end
    end
  end

  def remove_component
    @supplement_component = @user_supplement.supplement_components.find(params[:component_id])
    @supplement_component.destroy

    respond_to do |format|
      format.html { redirect_to user_supplement_path(@user_supplement), notice: "Component was successfully removed." }
      format.turbo_stream do
        flash.now[:notice] = "Component was successfully removed."
        render turbo_stream: [
          turbo_stream.update("components_list", partial: "user_supplements/components/list", locals: { user_supplement: @user_supplement }),
          turbo_stream.update("flash_messages", partial: "shared/flash_messages")
        ]
      end
    end
  end

  def select_multiple
    @health_conditions = current_user.health_conditions
    @health_goals = current_user.health_goals
  end

  def add_multiple
    # Implementation for adding multiple supplements at once
  end

  private

  def set_user_supplement
    @user_supplement = current_user.user_supplements.find(params[:id])
  end

  def user_supplement_params
    params.require(:user_supplement).permit(
      :user_supplement_name, 
      :form, 
      :frequency, 
      :dosage, 
      :dosage_unit, 
      :manufacturer,
      :notes,
      health_condition_ids: [], 
      health_goal_ids: [],
      supplement_components_attributes: [:id, :supplement_component_name, :amount, :unit, :_destroy],
      supplement_health_conditions_attributes: [:id, :health_condition_id, :_destroy],
      supplement_health_goals_attributes: [:id, :health_goal_id, :_destroy]
    )
  end

  def component_params
    params.require(:supplement_component).permit(:supplement_component_name, :amount, :unit)
  end
  
  def update_health_conditions(health_condition_ids)
    # Clear existing associations
    @user_supplement.supplement_health_conditions.destroy_all
    
    # Add new associations based on checkboxes
    health_condition_ids.each do |hc_id|
      @user_supplement.supplement_health_conditions.create(health_condition_id: hc_id)
    end
  end
  
  def update_health_goals(health_goal_ids)
    # Clear existing associations
    @user_supplement.supplement_health_goals.destroy_all
    
    # Add new associations based on checkboxes
    health_goal_ids.each do |hg_id|
      @user_supplement.supplement_health_goals.create(health_goal_id: hg_id)
    end
  end
end
