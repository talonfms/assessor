module Public
  class SurveyResponsesController < ApplicationController
    before_action :set_assessment

    def show
      @template_version = @assessment.template_version
      @survey_response = @assessment.survey_responses.new
    end

    def create
      @survey_response = @assessment.survey_responses.new(survey_response_params)

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

    def survey_response_params
      params.require(:survey_response).permit(
        responses_attributes: [:block_id, :response_data, response_data: [:text, :block_option_id]]
      )
    end
  end
end
