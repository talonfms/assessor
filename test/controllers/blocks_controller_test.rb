require "test_helper"

class BlocksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:admin)
    @account = accounts(:one)
    @account_user = account_users(:one)
    @account_user.update(account: @account, user: @user)

    @survey_template = survey_templates(:one)
    @survey_template.update(account: @account)

    @template_version = template_versions(:one)
    @template_version.update(survey_template: @survey_template)

    @block = blocks(:one)
    @block.update(template_version: @template_version)

    sign_in @user
    Current.account = @account
  end

  test "should create block" do
    assert_difference("Block.count") do
      post survey_template_template_version_blocks_url(@survey_template, @template_version), params: {
        block: {
          block_type: "short_text",
          question: "Test question"
        }
      }
    end

    assert_redirected_to survey_template_template_version_path(@survey_template, @template_version, block_id: Block.last.id)
  end

  test "should create block after existing block" do
    assert_difference("Block.count") do
      post survey_template_template_version_blocks_url(@survey_template, @template_version), params: {
        block: {
          block_type: "short_text",
          question: "Test question"
        },
        block_id: @block.id
      }
    end

    new_block = Block.last
    assert_equal @block.position + 1, new_block.position
    assert_redirected_to survey_template_template_version_path(@survey_template, @template_version, block_id: new_block.id)
  end

  test "should update block" do
    patch survey_template_template_version_block_url(@survey_template, @template_version, @block), params: {
      block: {
        question: "Updated question"
      }
    }

    @block.reload
    assert_equal "Updated question", @block.question
  end

  test "should destroy block" do
    assert_difference("Block.count", -1) do
      delete survey_template_template_version_block_url(@survey_template, @template_version, @block)
    end

    assert_redirected_to edit_survey_template_path(@survey_template)
  end

  test "should reorder blocks" do
    block2 = @template_version.blocks.create!(block_type: "short_text", position: 2, question: "Block 2")
    block3 = @template_version.blocks.create!(block_type: "short_text", position: 3, question: "Block 3")

    post reorder_survey_template_template_version_block_url(@survey_template, @template_version, @block), params: {
      block_ids: [block3.id, block2.id, @block.id]
    }

    assert_response :success

    @block.reload
    block2.reload
    block3.reload

    assert_equal 3, @block.position
    assert_equal 2, block2.position
    assert_equal 1, block3.position
  end

  test "should apply default options on create" do
    post survey_template_template_version_blocks_url(@survey_template, @template_version), params: {
      block: {
        block_type: "short_text",
        question: "Test question"
      }
    }

    new_block = Block.last
    assert_not_nil new_block.min_length
    assert_not_nil new_block.max_length
  end

  test "should handle invalid block creation" do
    post survey_template_template_version_blocks_url(@survey_template, @template_version), params: {
      block: {
        question: "Test question"
      }
    }

    assert_response :unprocessable_entity
  end
end
