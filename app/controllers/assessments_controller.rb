class AssessmentsController < ApplicationController
  before_action :set_assessment, only: [:show, :edit, :update, :destroy, :download_bundle, :download_analysis]

  # GET /assessments
  def index
    @pagy, @assessments = pagy(current_account.assessments.sort_by_params(params[:sort], sort_direction))

    # Uncomment to authorize with Pundit
    # authorize @assessments
  end

  # GET /assessments/1 or /assessments/1.json
  def show
  end

  # GET /assessments/new
  def new
    @assessment = Assessment.new

    # Uncomment to authorize with Pundit
    # authorize @assessment
  end

  # GET /assessments/1/edit
  def edit
  end

  # POST /assessments or /assessments.json
  def create
    @assessment = current_account.assessments.build(assessment_params)
    if @assessment.include_sow_check == "1"
      @assessment.build_sow_check
    end
    if @assessment.include_finance_check == "1"
      @assessment.build_finance_check
    end
    if @assessment.template_version_id.present?
      @assessment.build_survey_check
    end
    # Uncomment to authorize with Pundit
    # authorize @assessment

    respond_to do |format|
      if @assessment.save
        format.html { redirect_to @assessment, notice: "Assessment was successfully created." }
        format.json { render :show, status: :created, location: @assessment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assessments/1 or /assessments/1.json
  def update
    if assessment_params[:remove_file] == "true" && @assessment.file.attached?
      @assessment.file.purge
      @assessment.update!(status: "submitted")

      respond_to do |format|
        format.html { redirect_to @assessment, notice: I18n.t("assessments.show.successfully_removed") }
        format.json { render :show, status: :ok, location: @assessment }
      end
      return
    end

    respond_to do |format|
      if @assessment.update(assessment_params)
        if @assessment.file.attached? && assessment_params[:file].present?
          @assessment.update!(status: "completed")
          AssessmentsMailer.new_analysis(@assessment).deliver_later
        end

        if @assessment.submitted?
          ExportBundle.find_or_create_by(assessment_id: @assessment.id)
          ::ExportBundleWorker.perform_async(@assessment.id)
        end

        format.html { redirect_to @assessment, notice: "Assessment was successfully updated." }
        format.json { render :show, status: :ok, location: @assessment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assessments/1 or /assessments/1.json
  def destroy
    @assessment.destroy!
    respond_to do |format|
      format.html { redirect_to assessments_url, status: :see_other, notice: "Assessment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def download_bundle
    return unless @assessment.submitted? && @assessment.export_bundle&.completed?

    if @assessment.export_bundle.file.attached?
      redirect_to rails_blob_path(@assessment.export_bundle.file, disposition: "attachment")
    else
      redirect_to assessment_path(@assessment), alert: I18n.t("assessments.download_bundle.no_file")
    end
  end

  def download_analysis
    if @assessment.file.attached?
      redirect_to rails_blob_path(@assessment.file, disposition: "attachment")
    else
      redirect_to assessment_path(@assessment), alert: I18n.t("assessments.download_analysis.no_file")
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_assessment
    @assessment = current_account.assessments.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @assessment
  rescue ActiveRecord::RecordNotFound
    redirect_to assessments_path
  end

  # Only allow a list of trusted parameters through.
  def assessment_params
    params.require(:assessment).permit(:name, :include_sow_check, :include_finance_check, :status, :template_version_id, :file, :remove_file)

    # Uncomment to use Pundit permitted attributes
    # params.require(:assessment).permit(policy(@assessment).permitted_attributes)
  end
end
