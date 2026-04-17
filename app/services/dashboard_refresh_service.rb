class DashboardRefreshService
  TITLE_TO_KEY = {
    "Key Theme 1"                => "key_theme_1",
    "Key Theme 2"                => "key_theme_2",
    "Key Theme 3"                => "key_theme_3",
    "Frustrations & Pain Points" => "frustrations_and_pain_points",
    "Strengths & Positive Feedback" => "strengths_and_positive_feedback",
    "Suggested Improvements"     => "suggested_improvements",
  }.freeze

  def initialize(product)
    @product = product
  end

  def call
    cards = DashboardCard.where(product: @product)
    enrich_database(cards)

    chat = RubyLLM.chat(model: "gpt-4o-mini")
    chat.with_instructions(DashboardPrompt.content)
    response = chat.ask(user_message(cards))

    update_cards(cards, JSON.parse(response.content))

  rescue JSON::ParserError => e
    Rails.logger.error "DashboardRefreshService JSON parse error: #{e.message}"
    { error: "LLM returned invalid JSON" }
  rescue StandardError => e
    Rails.logger.error "DashboardRefreshService error: #{e.message}"
    { error: e.message }
  end

  private

  def enrich_database(cards)
    needs_enrichment = cards.any? { |c| c.last_enriched_at.nil? || c.last_enriched_at < 24.hours.ago }
    if needs_enrichment
      DbEnrichmentJob.perform_later(@product, "#{@product.name} #{@product.brand}", first_enrichment: cards.all? { |c| c.last_enriched_at.nil? })
    end
    cards.each do |card|
      if card.last_enriched_at.nil?
        DbEnrichmentJob.perform_later(@product, "#{@product.name} #{@product.brand} #{card.title}", first_enrichment: true)
      elsif card.last_enriched_at < 24.hours.ago
        DbEnrichmentJob.perform_later(@product, "#{@product.name} #{@product.brand} #{card.title}")
      end
    end
  end

  def user_message(cards)
    cards_context = cards.map do |card|
      posts = PostsDatabaseService.new(@product, card.title).call
      posts_text = posts.map { |p| p.content }.join("\n---\n")
      "Card: #{card.title}\nCurrent content: #{card.content}\nRelevant comments:\n#{posts_text}"
    end.join("\n\n===\n\n")

    <<~MSG
      #{cards_context}
    MSG
  end

  def update_cards(cards, llm_response)
    cards.each do |card|
      key = TITLE_TO_KEY[card.title]
      next unless key && llm_response[key]

      data = llm_response[key]
      new_title = data["title"].present? ? data["title"] : card.title
      raw_content = data["content"]
      content = raw_content.is_a?(String) ? raw_content : raw_content.to_json

      card.update!(title: new_title, content: content)
      Turbo::StreamsChannel.broadcast_replace_to(
        @product,
        target: ActionView::RecordIdentifier.dom_id(card),
        partial: "dashboard_cards/dashboard_card",
        locals: { dashboard_card: card }
      )
    end
  end
end
