# frozen_string_literal: true

class LabelComponent < ViewComponent::Base
  def initialize(text:, type: :default)
    @text = text
    @type = type
  end

  private

  def background_color_class
    case @type
    when :success
      "bg-green-100 dark:bg-green-700"
    when :warning
      "bg-yellow-100 dark:bg-yellow-700"
    when :error
      "bg-red-100 dark:bg-red-700"
    when :info
      "bg-blue-100 dark:bg-blue-700"
    else
      "bg-gray-100 dark:bg-gray-700"
    end
  end

  def text_color_class
    case @type
    when :success
      "text-green-800 dark:text-green-200"
    when :warning
      "text-yellow-800 dark:text-yellow-200"
    when :error
      "text-red-800 dark:text-red-200"
    when :info
      "text-blue-800 dark:text-blue-200"
    else
      "text-gray-800 dark:text-gray-200"
    end
  end
end
