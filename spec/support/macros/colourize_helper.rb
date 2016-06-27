module ColourizeHelper
  def colourize(colour_code, str)
    "\e[#{colour_code}m#{str}\e[0m"
  end

  def red(str)
    colourize(31, str)
  end

  def green(str)
    colourize(32, str)
  end

  def yellow(str)
    colourize(33, str)
  end

  def blue(str)
    colourize(34, str)
  end

  def pink(str)
    colourize(35, str)
  end

  def light_blue(str)
    colourize(36, str)
  end
end
