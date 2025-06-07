class MedicationsController < ApplicationController
  include Pager

  before_action :authenticate_admin!
  before_action :set_medication, only: %i[ show destroy ]

  # GET /medications or /medications.json
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

  # GET /medications/1 or /medications/1.json
  def show
  end

  # DELETE /medications/1 or /medications/1.json
  def destroy
    @medication.destroy

    set_pager_params

    respond_to do |format|
      format.html { redirect_to medications_path, status: :see_other, flash: { notice: "Medication was successfully deleted." } }
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
      format.html { redirect_to medications_path }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_medication
    @medication = Medication.find(params[:id])
  end

  # Pager override
  def set_pager_pagination_path
    @pager_pagination_path = medications_path
  end

  # Pager override
  def set_pager_rows_changed_action_path
    @pager_rows_changed_action_path = pager_rows_changed_medications_path
  end

  # Pager override
  def pager_records_collection
    Medication.ordered
  end

  def pagination_turbo_stream(records:, paginator:)
    [
      turbo_stream.update(
        "pager_results",
        partial: "medications/list/list",
        locals: { medications: @records }
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