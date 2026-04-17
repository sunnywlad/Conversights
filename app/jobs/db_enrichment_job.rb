class DbEnrichmentJob < ApplicationJob
  queue_as :default

  def perform(product, query, chat: nil, order: 'relevance')
    YoutubeCommentsService.new(product, query: query, order: order).call
    if chat
      now = Time.current
      chat.update(last_enriched_at: now)
      chat.dashboard_card.update(last_enriched_at: now) if chat.dashboard_card.present?
    end
  end
end
