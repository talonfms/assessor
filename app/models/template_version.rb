class TemplateVersion < ApplicationRecord
  belongs_to :survey_template
  belongs_to :created_by, class_name: "User"

  has_many :blocks, -> { order(position: :asc) }, dependent: :destroy
  has_many :block_groups, dependent: :destroy
  has_many :assessments, dependent: :destroy

  validates :version_number, presence: true, uniqueness: {scope: :survey_template_id}
  validates :survey_template, presence: true

  scope :locked, -> { where.not(locked_at: nil) }
  scope :unlocked, -> { where(locked_at: nil) }
  scope :latest_first, -> { order(version_number: :desc) }

  def locked?
    locked_at.present?
  end

  def lock!
    update!(locked_at: Time.current) unless locked?
  end

  def self.create_new_version(survey_template)
    latest_version = survey_template.template_versions.order(version_number: :desc).first

    transaction do
      version = create!(
        survey_template: survey_template,
        version_number: (latest_version&.version_number || 0) + 1
      )

      # Deep clone the question structure
      latest_version&.blocks&.each do |block|
        new_block = block.dup
        new_block.template_version = version
        new_block.save!

        block.block_options.each do |block_option|
          new_block_option = block_option.dup
          new_block_option.block = new_block
          new_block_option.save!
        end
      end

      version
    end
  end
end
