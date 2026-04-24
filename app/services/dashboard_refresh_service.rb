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
    raw_comments = fetch_raw_comments(cards)

    llm_chat = RubyLLM.chat(model: "gpt-4o-mini")
    llm_chat.with_instructions(DashboardPrompt.content)
    response = llm_chat.ask(user_message(cards, raw_comments))

    llm_response = JSON.parse(response.content)
    update_cards(cards, llm_response)
    update_sentiment(llm_response)

    new_posts = YoutubeCommentsService.new(@product).save(raw_comments)
    new_posts.each_with_index do |post, index|
      SetEmbeddingJob.set(wait: 1.minute + (index * 3).seconds).perform_later(post)
    end

  rescue JSON::ParserError => e
    Rails.logger.error "DashboardRefreshService JSON parse error: #{e.message}"
    { error: "LLM returned invalid JSON" }
  rescue StandardError => e
    Rails.logger.error "DashboardRefreshService error: #{e.message}"
    { error: e.message }
  end

  private

  def fetch_raw_comments(cards)
    first_time = cards.all? { |c| c.last_enriched_at.nil? }
    if first_time
      YoutubeCommentsService.new(@product, query: "#{@product.name} #{@product.brand}", target: 25).fetch_raw
    else
      stale_cards = cards.select { |c| c.last_enriched_at < 1.hour.ago }
      stale_cards.flat_map do |card|
        YoutubeCommentsService.new(@product, query: "#{@product.name} #{@product.brand} #{card.title}").fetch_raw
      end.uniq
    end
  end

  def user_message(cards, raw_comments)
    raw_text = raw_comments.join("\n---\n")
    vectors = rag_vectors_for(cards)

    cards_context = cards.each_with_index.map do |card, i|
      rag_text = if vectors
        rag_posts = Post.where(product_id: @product.id)
                        .where.not(embedding: nil)
                        .nearest_neighbors(:embedding, vectors[i], distance: "euclidean")
                        .first(10)
        rag_posts.map(&:content).join("\n---\n")
      end

      card_str = "Card: #{card.title}\nCurrent content: #{card.content}"
      card_str += "\nRelated stored comments:\n#{rag_text}" if rag_text.present?
      card_str
    end.join("\n\n===\n\n")

    sections = []
    sections << "New comments:\n#{raw_text}" if raw_text.present?
    sections << cards_context
    sections.join("\n\n===\n\n")
  end

  def rag_vectors_for(cards)
    return nil unless Post.where(product_id: @product.id).where.not(embedding: nil).exists?

    result = RubyLLM.embed(cards.map(&:title))
    result.vectors
  end

  def update_sentiment(llm_response)
    data = llm_response["overall_sentiment"]
    return unless data && data["score"].present?

    @product.update!(sentiment_score: data["score"], sentiment_label: data["label"])
    Turbo::StreamsChannel.broadcast_replace_to(
      @product,
      target: "sentiment-badge",
      partial: "products/sentiment_badge",
      locals: { product: @product }
    )
  end

  def update_cards(cards, llm_response)
    cards.each do |card|
      key = TITLE_TO_KEY[card.title]
      next unless key && llm_response[key]

      data = llm_response[key]
      new_title = data["title"].present? ? data["title"] : card.title
      raw_content = data["content"]
      content = raw_content.is_a?(String) ? raw_content : raw_content.to_json

      card.update!(title: new_title, content: content, last_enriched_at: Time.current)
      Turbo::StreamsChannel.broadcast_replace_to(
        @product,
        target: ActionView::RecordIdentifier.dom_id(card),
        partial: "dashboard_cards/dashboard_card",
        locals: { dashboard_card: card }
      )
    end
  end
end
