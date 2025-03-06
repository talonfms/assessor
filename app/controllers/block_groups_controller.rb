class BlockGroupsController < ApplicationController
  before_action :set_template_version

  def create
    @block_group = @template_version.block_groups.build(block_group_params)
    @block = params[:block_id].present? ? @template_version.blocks.find(params[:block_id]) : nil
    if @block_group.save
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            # Refresh the entire form instead of just the select
            turbo_stream.replace(
              "block-form",
              partial: "blocks/form",
              locals: {
                template_version: @template_version,
                block: @block  # You might need to set this in a before_action
              }
            ),
            # Close the modal
            turbo_stream.append("body",
              "<script>document.querySelector('#newBlockGroupModal').close()</script>")
          ]
        }
        format.html { redirect_to @template_version, notice: "Block group was successfully created." }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "new_block_group",
            partial: "blocks/new_block_group_form",
            locals: {template_version: @template_version, block_group: @block_group}
          )
        }
        format.html { render "blocks/_form", status: :unprocessable_entity }
      end
    end
  end

  private

  def set_template_version
    @template_version = TemplateVersion.find(params[:template_version_id])
  end

  def block_group_params
    params.require(:block_group).permit(:name, :description)
  end
end
