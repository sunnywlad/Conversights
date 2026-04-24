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

  def capitalize_sentences(text)
    text&.gsub(/(\A|[.!?]\s+)([a-z])/) { $1 + $2.upcase }
  end

  def render_markdown(text)
    normalized = text
      .gsub(/([^\n])\n(#+\s)/, "\\1\n\n\\2")
      .gsub(/^(#+\s+\S.*?)([a-z])([A-Z])/) { "#{$1}#{$2}\n\n#{$3}" }
      .gsub(/(#+\s[^\n]+)\n([^\n#])/, "\\1\n\n\\2")
    Kramdown::Document.new(normalized, input: 'GFM', syntax_highlighter: "rouge").to_html
  end
end
