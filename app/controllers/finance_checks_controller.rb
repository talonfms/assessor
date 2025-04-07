class FinanceChecksController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_finance_check, only: [:update]

  def update
    if finance_check_params[:remove_file] == "true" && finance_check_params[:file_id].present?
      attachment = ActiveStorage::Attachment.find_by(id: finance_check_params[:file_id])
      if attachment
        attachment.purge

        respond_to do |format|
          format.html { redirect_to @finance_check.assessment, notice: I18n.t("assessments.show.successfully_removed") }
          format.json { render :show, status: :ok, location: @finance_check.assessment }
        end
      end
      return
    end
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
    params.require(:finance_check).permit(:remove_file, :file_id, files: [])
  end
end
