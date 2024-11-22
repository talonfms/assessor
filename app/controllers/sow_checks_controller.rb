class SowChecksController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_sow_check, only: [:update]

  def update
    if @sow_check.update(sow_check_params)
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            dom_id(@sow_check.assessment),
            partial: "assessments/assessment",
            locals: {assessment: @sow_check.assessment}
          )
        }
        format.html { redirect_to @sow_check.assessment }
      end
      @sow_check.assessment.touch
    else
      # Handle error case
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.update(
            "flash",
            partial: "shared/flash",
            locals: {message: "Failed to upload files", type: "error"}
          )
        }
        format.html { redirect_to @sow_check.assessment, alert: "Failed to upload files" }
      end
    end
  end

  private

  def set_sow_check
    @sow_check = SowCheck.find(params[:id])
  end

  def sow_check_params
    params.require(:sow_check).permit(files: [])
  end
end
