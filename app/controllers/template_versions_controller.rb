class TemplateVersionsController < ApplicationController
  before_action :set_survey_template
  before_action :check_admin
  before_action :check_is_parent_account

  def create
    @template_version = if @latest_version.present?
      @survey_template.template_versions.build(notes: I18n.t("template_versions.create.notes", version_number: @latest_version.version_number + 1), created_by: current_user, version_number: @latest_version.version_number + 1)
    else
      @survey_template.template_versions.build(
        version_number: 1,
        created_by: current_user,
        notes: "Initial version"
      )
    end

    if @latest_version&.blocks.present?
      @template_version.blocks = @latest_version.blocks.map do |original_block|
        new_block = original_block.dup

        if original_block.block_options.present?
          new_block.block_options = original_block.block_options.map do |option|
            new_option = option.dup
            new_option
          end
        end

        new_block
      end
    end

    respond_to do |format|
      if @template_version.save
        format.html { redirect_to survey_template_template_version_path(@survey_template, @template_version), notice: "Template version was successfully created." }
        format.json { render :show, status: :created, location: @template_version }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @template_version.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    flash[:notice] = I18n.t("template_versions.show.in_progress_assessments") if @template_version.version_number > 1
  end

  def preview
    @survey_response = SurveyResponse.new
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
    @survey_template = current_account.survey_templates.find(params[:survey_template_id])
    @template_version = @survey_template.template_versions.find(params[:id]) if params[:id].present?
    @latest_version = @survey_template.latest_version
    @blocks = @template_version.blocks if @template_version.present?
    @block = @blocks.find_by(id: params[:block_id]) || @blocks.first if @template_version.present?
  # Uncomment to authorize with Pundit
  # authorize @survey_template
  rescue ActiveRecord::RecordNotFound
    redirect_to survey_templates_path
  end
end
