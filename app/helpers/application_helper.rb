module ApplicationHelper
  INSIGHT_CARD_VISUALS = {
    "Key Theme 1"                   => { icon: "fa-lightbulb" },
    "Key Theme 2"                   => { icon: "fa-lightbulb" },
    "Key Theme 3"                   => { icon: "fa-lightbulb" },
    "Frustrations & Pain Points"    => { icon: "fa-triangle-exclamation" },
    "Strengths & Positive Feedback" => { icon: "fa-heart" },
    "Suggested Improvements"        => { icon: "fa-wand-magic-sparkles" },
  }.freeze

  def insight_card_visual(title)
    INSIGHT_CARD_VISUALS[title] || { icon: "fa-square" }
  end

  def render_markdown(text)
    Kramdown::Document.new(text, input: 'GFM', syntax_highlighter: "rouge").to_html
  end
end
