class UserMedicationsController < ApplicationController
  include Pager

  before_action :authenticate_user!
  before_action :set_user_medication, only: %i[ show edit update destroy ]

  # GET /user_medications or /user_medications.json
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

  # GET /user_medications/1 or /user_medications/1.json
  def show
  end

  # GET /user_medications/new
  def new
    @user_medication = current_user.user_medications.new
    @user_medication.build_medication # Build a new medication for the nested form
  end

  # GET /user_medications/1/edit
  def edit
  end

  # GET /user_medications/search
  def search
    if params[:search].present?
      search_results = Medications::Rxnorm::SearchService.search(params[:search])
      render json: { medications: search_results.medication_names }
    else
      render json: { medications: [] }
    end
  end

  # POST /user_medications or /user_medications.json
  def create
    @user_medication = current_user.user_medications.new(user_medication_params)

    # Set the user_id explicitly
    @user_medication.user_id = current_user.id

    # Handle the case when medication_id is provided (existing medication)
    if params[:user_medication][:medication_id].present?
      @user_medication.medication_id = params[:user_medication][:medication_id]
      @user_medication.medication = nil # Don't create a new medication in this case
    end

    # Handle case when medication attributes are provided (new medication)
    if params[:user_medication][:medication_attributes].present? && params[:user_medication][:medication_attributes][:medication_name].present?
      medication_name = params[:user_medication][:medication_attributes][:medication_name]
      # Check if medication already exists
      existing_medication = Medication.find_by_medication_name(medication_name)

      if existing_medication
        # Use existing medication instead of creating new one
        @user_medication.medication = existing_medication
      end
      # If medication doesn't exist, the nested attributes will create it
    end

    if @user_medication.save
      redirect_to user_medications_path, notice: "Medication was successfully added to your list."
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    @user_medication.errors.add(:base, e.record.errors.full_messages.to_sentence)
    render :new, status: :unprocessable_entity
  end

  # PATCH/PUT /user_medications/1 or /user_medications/1.json
  def update
    if @user_medication.update(user_medication_params)
      redirect_to user_medications_path, notice: "Medication was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /user_medications/1 or /user_medications/1.json
  def destroy
    @user_medication.destroy

    set_pager_params

    respond_to do |format|
      format.html { redirect_to user_medications_path, notice: "Medication was successfully removed." }
      format.turbo_stream do
        flash.now[:notice] = "Medication was successfully removed."
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
      format.html { redirect_to user_medications_path }
    end
  end

  private

  def set_user_medication
    @user_medication = current_user.user_medications.find(params[:id])
  end

  def medication_params
    params.require(:medication).permit(:medication_name)
  end

  def user_medication_params
    params.require(:user_medication).permit(:medication_id, :frequency, medication_attributes: [ :medication_name ])
  end

  # Pager override
  def set_pager_pagination_path
    @pager_pagination_path = user_medications_path
  end

  # Pager override
  def set_pager_rows_changed_action_path
    @pager_rows_changed_action_path = pager_rows_changed_user_medications_path
  end

  # Pager override
  def pager_records_collection
    current_user.user_medications.ordered
  end

  def pagination_turbo_stream(records:, paginator:)
    [
      turbo_stream.update(
        "pager_results",
        partial: "user_medications/list/list",
        locals: { user_medications: @records }
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
