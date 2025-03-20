# app/controllers/blocks_controller.rb
class BlocksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template_version
  before_action :set_block, only: %i[edit update destroy reorder]
  #  before_action :ensure_admin

  def new
    @block = @template_version.blocks.new
    render layout: false
  end

  def create
    if params[:block_id].present?
      current_block = @template_version.blocks.find(params[:block_id])
      current_block_group = current_block.block_group
    end
    next_position = if current_block.present?
      current_block.position + 1
    else
      current_block_group.present? ? current_block_group.blocks.maximum(:position).to_i + 1 : @template_version.blocks.ungrouped.maximum(:position).to_i + 1
    end
    @block = @template_version.blocks.new(block_params.merge(position: next_position, required: "0", button_text: "Next",
      question: "How are you doing?", block_group_id: current_block_group&.id))
    @block.apply_default_options
    if @block.save
      redirect_to edit_survey_template_path(@survey_template, block_id: @block.id)
    else
      render json: {success: false, errors: @block.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def edit
    render layout: false
  end

  def update
    if @block.update(block_params)
      respond_to do |format|
        format.turbo_stream
      end
    else
      render json: {success: false, errors: @block.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    @block.destroy
    redirect_to edit_survey_template_path(@survey_template)
  end

  def reorder
    params[:block_ids].each_with_index do |id, index|
      Block.where(id:).update_all(position: index + 1)
    end
    head :ok
  end

  private

  def set_template_version
    @template_version = current_account.template_versions.find(params[:template_version_id])
    @survey_template = @template_version.survey_template
  end

  def set_block
    @block = @template_version.blocks.find(params[:id])
  end

  def ensure_admin
    return if current_user.admin?

    render json: {error: "Unauthorized"}, status: :unauthorized
  end

  def block_params
    params.require(:block).permit(:block_type, :question, :position, :button_text, :required,
      :block_group_id, :description, :placeholder, :min_length, :max_length,
      :min_value, :max_value, :date_format, :min_date, :max_date,
      :randomize_options,
      block_options_attributes: %i[id key _destroy position])
  end
end
