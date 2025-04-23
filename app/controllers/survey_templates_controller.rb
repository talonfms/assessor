class SurveyTemplatesController < ApplicationController
  before_action :set_survey_template, only: [:show, :edit, :update, :destroy]
  before_action :check_admin
  before_action :check_is_parent_account

  # GET /survey_templates
  def index
    @pagy, @survey_templates = pagy(current_account.survey_templates.sort_by_params(params[:sort], sort_direction))

    # Uncomment to authorize with Pundit
    # authorize @survey_templates
  end

  # GET /survey_templates/1 or /survey_templates/1.json
  def show
  end

  # GET /survey_templates/new
  def new
    @survey_template = SurveyTemplate.new

    # Uncomment to authorize with Pundit
    # authorize @survey_template
  end

  # GET /survey_templates/1/edit
  def edit
    @blocks = @template_version.blocks.includes(:block_options)
    @block = @blocks.find_by(id: params[:block_id]) || @blocks.first
  end

  # POST /survey_templates or /survey_templates.json
  def create
    @survey_template = nil
    SurveyTemplate.transaction do
      @survey_template = current_account.survey_templates.build(survey_template_params)

      # Uncomment to authorize with Pundit
      # authorize @survey_template
      if @survey_template.save
        respond_to do |format|
          format.html { redirect_to @survey_template, notice: "Survey template was successfully created." }
          format.json { render :show, status: :created, location: @survey_template }
        end
      else
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @survey_template.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /survey_templates/1 or /survey_templates/1.json
  def update
    respond_to do |format|
      if @survey_template.update(survey_template_params)
        format.html { redirect_to @survey_template, notice: "Survey template was successfully updated." }
        format.json { render :show, status: :ok, location: @survey_template }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @survey_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_templates/1 or /survey_templates/1.json
  def destroy
    @survey_template.destroy!
    respond_to do |format|
      format.html { redirect_to survey_templates_url, status: :see_other, notice: "Survey template was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def check_admin
    return true if Current.account_user&.admin?

    redirect_to assessments_path, alert: I18n.t("errors.messages.not_authorized")
  end

  def check_is_parent_account
    return true if current_account&.is_parent?

    redirect_to assessments_path, alert: I18n.t("errors.messages.not_authorized")
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_survey_template
    @survey_template = current_account.survey_templates.find(params[:id])
    @template_version = @survey_template.latest_version
    # Uncomment to authorize with Pundit
    # authorize @survey_template
  rescue ActiveRecord::RecordNotFound
    redirect_to survey_templates_path
  end

  # Only allow a list of trusted parameters through.
  def survey_template_params
    params.require(:survey_template).permit(:name, :description, :account_id)

    # Uncomment to use Pundit permitted attributes
    # params.require(:survey_template).permit(policy(@survey_template).permitted_attributes)
  end
end
