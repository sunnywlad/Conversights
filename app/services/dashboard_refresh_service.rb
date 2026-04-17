class DashboardRefreshService
  TITLE_TO_KEY = {
    "Overall Sentiment"             => "overall_sentiment",
    "Key Theme 1"                   => "key_theme_1",
    "Key Theme 2"                   => "key_theme_2",
    "Key Theme 3"                   => "key_theme_3",
    "Frustrations & Pain Points"    => "frustrations_and_pain_points",
    "Strengths & Positive Feedback" => "strengths_and_positive_feedback",
  }.freeze

  def initialize(product)
    @product = product
  end

  def call
    cards = DashboardCard.where(product: @product)
    posts = FetchYoutubeCommentsService.new(@product).call

    chat = RubyLLM.chat(model: "gpt-4o-mini")
    chat.with_instructions(DashboardPrompt.content)
    response = chat.ask(user_message(cards, posts))

    update_cards(cards, JSON.parse(response.content))

  rescue JSON::ParserError => e
    Rails.logger.error "DashboardRefreshService JSON parse error: #{e.message}"
    { error: "LLM returned invalid JSON" }
  rescue StandardError => e
    Rails.logger.error "DashboardRefreshService error: #{e.message}"
    { error: e.message }
  end

  private

  def user_message(cards, posts)
    <<~MSG
      Existing dashboard cards:
      #{cards.map { |c| { title: c.title, content: c.content } }.to_json}

      YouTube comments to analyze:
      #{posts.to_json}
    MSG
  end

  def update_cards(cards, llm_response)
    cards.each do |card|
      key = TITLE_TO_KEY[card.title]
      next unless key && llm_response[key]

      data = llm_response[key]
      new_title = data["title"].presence || card.title
      content = serialize_content(key, data)

      card.update!(title: new_title, content: content)
      Turbo::StreamsChannel.broadcast_replace_to(
        @product,
        target: ActionView::RecordIdentifier.dom_id(card),
        partial: "dashboard_cards/dashboard_card",
        locals: { dashboard_card: card }
      )
    end
  end

  def serialize_content(key, data)
    if key == "overall_sentiment"
      { score: data["score"], label: data["label"] }.to_json
    else
      raw = data["content"]
      raw.is_a?(String) ? raw : raw.to_json
    end
  end
end
