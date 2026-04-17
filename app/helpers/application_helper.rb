module ApplicationHelper
  INSIGHT_CARD_VISUALS = {
    "Overall Sentiment"             => { icon: "fa-gauge-high",    color: "purple" },
    "Key Theme 1"                   => { icon: "fa-lightbulb",     color: "blue" },
    "Key Theme 2"                   => { icon: "fa-lightbulb",     color: "green" },
    "Key Theme 3"                   => { icon: "fa-lightbulb",     color: "orange" },
    "Frustrations & Pain Points"    => { icon: "fa-triangle-exclamation", color: "orange" },
    "Strengths & Positive Feedback" => { icon: "fa-heart",         color: "green" },
  }.freeze

  def insight_card_visual(title)
    INSIGHT_CARD_VISUALS[title] || { icon: "fa-square", color: "blue" }
  end

  def render_markdown(text)
    Kramdown::Document.new(text, input: 'GFM', syntax_highlighter: "rouge").to_html
  end
end
