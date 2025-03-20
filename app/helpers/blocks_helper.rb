module BlocksHelper
  def block_icon(block, **)
    if block.short_text?
      heroicon("bars-2", **)
    elsif block.long_text?
      heroicon("paragraph", **)
    elsif block.single_select?
      heroicon("stop", **)
    end
  end
end
