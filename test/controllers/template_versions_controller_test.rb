require "test_helper"

class TemplateVersionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:admin)
    @account = accounts(:one)
    @account.update!(is_parent: true)
    @account_user = account_users(:one)
    @account_user.update(account: @account, user: @user, admin: true)

    @survey_template = survey_templates(:one)
    @survey_template.update(account: @account)

    @template_version = template_versions(:one)
    @template_version.update(
      survey_template: @survey_template,
      version_number: 1,
      notes: "Initial version"
    )

    @block = blocks(:one)
    @block.update(template_version: @template_version)

    sign_in @user
    Current.account = @account
  end

  test "should create a new template version if one already exists" do
    assert_difference("TemplateVersion.count") do
      post survey_template_template_versions_url(@survey_template), params: {
        notes: "New version notes"
      }
    end

    new_version = TemplateVersion.last
    assert_equal @template_version.version_number + 1, new_version.version_number
    assert_equal @user.id, new_version.created_by_id
    assert_equal @template_version.blocks.count, new_version.blocks.count

    assert_redirected_to survey_template_template_version_path(@survey_template, new_version)
    assert_equal "Template version was successfully created.", flash[:notice]
  end

  test "should create a new template version if no template version exists" do
    @template_version.destroy
    assert_equal @survey_template.template_versions.count, 0
    assert_difference("TemplateVersion.count") do
      post survey_template_template_versions_url(@survey_template)
    end

    new_version = @survey_template.template_versions.last
    assert_equal 1, new_version.version_number
    assert_equal @user.id, new_version.created_by_id
    assert_equal "Initial version", new_version.notes

    assert_redirected_to survey_template_template_version_path(@survey_template, new_version)
    assert_equal "Template version was successfully created.", flash[:notice]
  end

  test "should show template version" do
    get survey_template_template_version_url(@survey_template, @template_version)
    assert_response :success

    version_two = @survey_template.template_versions.create!(
      version_number: 2,
      created_by: @user,
      notes: "Version 2"
    )

    get survey_template_template_version_url(@survey_template, version_two)
    assert_response :success
    assert_equal I18n.t("template_versions.show.in_progress_assessments"), flash[:notice]
  end

  test "should show preview" do
    get preview_survey_template_template_version_url(@survey_template, @template_version)
    assert_response :success
    assert_match @template_version.survey_template.name, @response.body
  end

  test "non-parent accounts cannot access template versions" do
    @account.update(is_parent: false)

    get survey_template_template_version_url(@survey_template, @template_version)
    assert_redirected_to assessments_path
    assert_equal I18n.t("errors.messages.not_authorized"), flash[:alert]

    post survey_template_template_versions_url(@survey_template), params: {
      notes: "Non-parent attempt"
    }
    assert_redirected_to assessments_path
    assert_equal I18n.t("errors.messages.not_authorized"), flash[:alert]
  end

  test "handles record not found gracefully" do
    get survey_template_template_version_url(@survey_template, 999)
    assert_redirected_to survey_templates_path

    get survey_template_template_version_url(999, @template_version)
    assert_redirected_to survey_templates_path
  end

  test "creates template version with duplicated blocks" do
    assert_equal 1, @block.block_options.count
    @block.update(
      question: "Original question",
      description: "Original description",
      required: true,
      block_type: "short_text"
    )

    option1 = @block.block_options.create!(key: "Option 1", value: "1")
    @block.block_options.create!(key: "Option 2", value: "2")

    assert_difference("TemplateVersion.count") do
      post survey_template_template_versions_url(@survey_template)
    end

    new_version = TemplateVersion.last
    new_block = new_version.blocks.first

    assert_equal @block.question, new_block.question
    assert_equal @block.description, new_block.description
    assert_equal @block.required, new_block.required
    assert_equal @block.block_type, new_block.block_type

    assert_equal 3, new_block.block_options.count
    assert_equal "Option 1", new_block.block_options.second.key
    assert_equal "Option 2", new_block.block_options.third.key

    assert_not_equal @block.id, new_block.id
    assert_not_equal option1.id, new_block.block_options.first.id
  end
end
