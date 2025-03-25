module Public
  class SurveyResponsesController < ApplicationController
    before_action :set_assessment
    before_action :add_blocks_for_users_without_accounts, only: :show

    def show
      @template_version = @assessment.template_version
      @survey_response = @assessment.survey_responses.new
    end

    def create
      @survey_response = @assessment.survey_responses.new(survey_response_params)
      if Current.user
        @survey_response.respondent_email = Current.user.email
        @survey_response.respondent_id = Current.user.id
      end

      if @survey_response.save
        redirect_to thank_you_public_survey_response_path(token: @assessment.token), notice: "Thank you for completing the survey!"
      else
        @template_version = @assessment.template_version
        render :show, status: :unprocessable_entity
      end
    end

    def thank_you
    end

    private

    def set_assessment
      @assessment = Assessment.find_by!(token: params[:token])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: "Survey not found"
    end

    def add_blocks_for_users_without_accounts
      @template_version = @assessment.template_version
      unless Block.where(template_version: @template_version, block_type: "short_text", question: "Full Name:").any?
        Block.create(
          block_type: "short_text",
          question: "Full Name:",
          position: 1,
          config: {"required" => "1", "max_length" => "100", "min_length" => "0",
                   "button_text" => "Next", "description" => "", "placeholder" => ""},
          template_version: @template_version
        )
      end

      unless Block.where(template_version: @template_version, block_type: "short_text", question: "Email:").any?
        Block.create(
          block_type: "short_text",
          question: "Email:",
          position: 2,
          config: {"required" => "1", "max_length" => "100", "min_length" => "0",
                   "button_text" => "Next", "description" => "", "placeholder" => ""},
          template_version: @template_version
        )
      end
    end

    def survey_response_params
      params.require(:survey_response).permit(
        responses_attributes: [:block_id, :response_data, response_data: [:text, :block_option_id]]
      )
    end
  end
end
