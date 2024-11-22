# frozen_string_literal: true

class RadialGaugeComponent < ViewComponent::Base
  MAX_PERCENTAGE = 75

  def initialize(text: nil, subtext: nil, type: :dynamic, value: 0, max: 100)
    @text = text
    @subtext = subtext
    @type = type
    @value = value
    @max = max
    if @type == :dynamic
      @type = (progress >= MAX_PERCENTAGE) ? :success : :default
    end
  end

  private

  def text_label
    @text || @value
  end

  def subtext_label
    @subtext || "/ #{@max}"
  end

  def progress
    return 0 if @value == 0
    ([@value, @max].min.to_f / @max.to_f) * MAX_PERCENTAGE
  end

  def gauge_color_class
    case @type
    when :success
      "text-green-200 dark:text-neutral-700"
    else
      "text-gray-200 dark:text-neutral-700"
    end
  end

  def progress_color_class
    case @type
    when :success
      "text-green-500 dark:text-green-500"
    else
      "text-blue-600 dark:text-blue-500"
    end
  end

  def value_color_class
    case @type
    when :success
      "text-green-600 dark:text-green-500"
    else
      "text-blue-600 dark:text-blue-500"
    end
  end
end
