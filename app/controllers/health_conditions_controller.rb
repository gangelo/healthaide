class HealthConditionsController < ApplicationController
  include Pager

  before_action :authenticate_admin!
  before_action :set_health_condition, only: %i[show edit update destroy]

  def index
    debug_show_pager_params do
        "#{self.class.name}#index:"
    end
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: pagination_turbo_stream(records: @records, paginator: @pagy)
      end
    end
  end

  def show
  end

  def new
    @health_condition = HealthCondition.new
  end

  def edit
  end

  def create
    @health_condition = HealthCondition.new(health_condition_params)

    if @health_condition.save
      redirect_to @health_condition, notice: "Health condition was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @health_condition.update(health_condition_params)
      redirect_to @health_condition, notice: "Health condition was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @health_condition.destroy

    set_pager_params

    respond_to do |format|
      format.html { redirect_to health_conditions_path, notice: "Health condition was successfully removed." }
      format.turbo_stream do
        flash.now[:notice] = "Health condition was successfully removed."
        turbo_stream_content = pagination_turbo_stream(records: @records, paginator: @pagy)
        turbo_stream_content << turbo_stream.update("flash_messages", partial: "shared/flash_messages")
        render turbo_stream: turbo_stream_content
      end
    end
  end

  # Pager override
  def pager_rows_changed
    respond_to do |format|
      format.turbo_stream do
        turbo_stream_content = pagination_turbo_stream(records: @records, paginator: @pagy)
        render turbo_stream: turbo_stream_content
      end
      format.html { redirect_to health_conditions_path }
    end
  end

  private

  def set_health_condition
    @health_condition = HealthCondition.find(params[:id])
  end

  def health_condition_params
    params.require(:health_condition).permit(:health_condition_name)
  end

  # Pager override
  def set_pager_pagination_path
    @pager_pagination_path = health_conditions_path
  end

  # Pager override
  def set_pager_rows_changed_action_path
    @pager_rows_changed_action_path = pager_rows_changed_health_conditions_path
  end

  # Pager override
  def pager_records_collection
    HealthCondition.ordered
  end

  def pagination_turbo_stream(records:, paginator:)
    [
      turbo_stream.update(
        "pager_results",
        partial: "health_conditions/list/list",
        locals: { health_conditions: @records }
      ),
      turbo_stream.update(
        "pagination_controls",
        partial: "shared/pager",
        locals: {
          pager_pagination_path: @pager_pagination_path,
          pagy: @pagy,
          pager_rows: @pager_rows
        }
      )
    ]
  end
end
