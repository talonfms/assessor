module ImagesHelper
  def render_logo(options = {})
    classes = options[:class] || "h-10 w-auto"
    default_logo_class = options[:default_logo_class] || "fill-current text-gray-500"

    logo_to_display = if current_account&.is_parent? && current_account.logo.attached?
      current_account.logo
    elsif current_account&.parent_account&.logo&.attached?
      current_account.parent_account.logo
    end

    if logo_to_display
      image_tag logo_to_display,
        alt: logo_to_display.record.name,
        class: classes
    else
      # Fallback to default Zivio logo when no account logo is available
      image_tag "zivio_logo.png",
        alt: "Zivio",
        class: classes
    end
  end

  def render_svg(name, options = {})
    options[:title] ||= name.underscore.humanize
    options[:aria] = true
    options[:nocomment] = true
    options[:class] = options.fetch(:styles, "fill-current text-gray-500")

    filename = "#{name}.svg"
    inline_svg_tag(filename, options)
  end

  # Font Awesome icon helper
  # fa_icon "thumbs-up", weight: "fa-solid"
  # <i class="fa-solid fa-thumbs-up"></i>
  def fa_icon(name, options = {})
    weight = options.delete(:weight) || "fa-regular"
    options[:class] = [weight, "fa-#{name}", options.delete(:class)]
    tag.i(nil, **options)
  end
end
