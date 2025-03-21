class Block < ApplicationRecord
  belongs_to :template_version
  has_many :responses, dependent: :destroy
  belongs_to :block_group, optional: true
  has_many :block_options, -> { order(position: :asc) }, dependent: :destroy

  accepts_nested_attributes_for :block_options, allow_destroy: true

  validates :block_type, presence: true
  validates :question, presence: true

  enum :block_type, {
    short_text: 0,
    long_text: 1,
    single_select: 2,
    multiple_select: 3,
    number: 4,
    date: 5,
    likert: 6
  }

  positioned on: :template_version

  store_accessor :config, :description, :button_text, :required, :randomize_options,
    :placeholder, :min_length, :max_length, :min_value, :max_value,
    :date_format, :min_date, :max_date

  scope :conditionally_exclude_email_and_full_name, -> {
    if Current.user.present?
      where.not(question: ["Email:", "Full Name:"])
    else
      all
    end
  }

  scope :ungrouped, -> { where(block_group_id: nil) }
  # validates :button_text, presence: true
  # validates :required, inclusion: { in: %w[0 1] }, allow_nil: true

  with_options if: :text_input? do
    # validates :min_length, :max_length, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
    # allow_nil: true
    # validate :max_length_greater_than_min_length
  end

  with_options if: :select_input? do
    validates :randomize_options, inclusion: {in: [true, false, "0", "1"]}
  end

  with_options if: :number_input? do
    validates :min_value, :max_value, numericality: true, allow_nil: true
    validate :max_value_greater_than_min_value
  end

  with_options if: :date_input? do
    validates :date_format, presence: true
    validate :valid_date_range
  end

  def options
    block_options.pluck(:value)
  end

  def option_keys
    block_options.pluck(:key)
  end

  def option_key_for_value(value)
    block_options.find_by(value:)&.key
  end

  def option_value_for_key(key)
    block_options.find_by(key:)&.value
  end

  def required?
    required == "1"
  end

  def apply_default_options
    case block_type
    when "short_text", "long_text"
      self.min_length ||= 0
      self.max_length ||= (block_type == "short_text") ? 100 : 1000
    when "number"
      self.min_value ||= 0
      self.max_value ||= 100
      self.decimal_places ||= 0
    when "date"
      self.min_date ||= Date.today
      self.max_date ||= Date.today + 1.year
    when "single_select", "multiple_select"
      self.randomize_options = false if randomize_options.nil?
      block_options.build(key: "Option 1", value: "1", position: 1) if block_options.empty?
    end
  end

  private

  def text_input?
    short_text? || long_text?
  end

  def select_input?
    single_select? || multiple_select?
  end

  def number_input?
    number?
  end

  def date_input?
    date?
  end

  def max_length_greater_than_min_length
    return unless min_length.present? && max_length.present? && max_length <= min_length

    errors.add(:max_length, "must be greater than min_length")
  end

  def max_value_greater_than_min_value
    return unless min_value.present? && max_value.present? && max_value <= min_value

    errors.add(:max_value, "must be greater than min_value")
  end

  def valid_date_range
    return unless min_date.present? && max_date.present? && max_date <= min_date

    errors.add(:max_date, "must be after min_date")
  end
end
