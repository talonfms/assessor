class FinanceChecksController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_finance_check, only: [:update]

  def update
    if @finance_check.update(finance_check_params)
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            dom_id(@finance_check.assessment),
            partial: "assessments/assessment",
            locals: {assessment: @finance_check.assessment}
          )
        }
        format.html { redirect_to @finance_check.assessment }
      end
      @finance_check.assessment.touch
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
        format.html { redirect_to @finance_check.assessment, alert: "Failed to upload files" }
      end
    end
  end

  private

  def set_finance_check
    @finance_check = FinanceCheck.find(params[:id])
  end

  def finance_check_params
    params.require(:finance_check).permit(files: [])
  end
end
