class BlockOptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_block_option, except: %i[new create]

  def update
    unless @block_option.update(position: params[:position])      
      render json: {success: false, errors: @block_option.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def new
    @block = Block.find(params[:block_id])
    @template_version = @block.template_version
    next_position = @block.block_options.maximum(:position).to_i + 1
    @block_option = @block.block_options.new(key: "Option #{next_position}", position: next_position)

    @block_option.save

      respond_to do |format|
        format.turbo_stream
        format.html # your existing response
    end
  end

  def destroy
    @block_option.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to edit_survey_template_path(@template_version.survey_template, block_id: @block.id) }
    end
  end

  def create
    @block = Block.find(params[:block_id])
    next_position = @block.block_options.maximum(:position).to_i + 1
    @block_option = @block.block_options.new(key: "Option #{next_position}", position: next_position)

    if @block_option.save
      redirect_to edit_survey_template_path(@block.template_version.survey_template, block_id: @block.id)
    else
      render json: {success: false, errors: @block_option.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def set_block_option
    @block_option = BlockOption.find(params[:id])
    @block = @block_option.block
    @template_version = @block.template_version
  end
end
