module HelpsHelper
  def render_help_steps(&block)
    steps = capture &block

    "<ol class=\"help\">#{steps}</ol>"
  end

  def render_help_step(title, &block)
    description = capture &block

    "<li><h3>#{h(title)}</h3>#{description}</li>"
  end
end
