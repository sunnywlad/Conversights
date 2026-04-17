class DbEnrichmentJob < ApplicationJob
  queue_as :default

  def perform(product, query, chat: nil, target: 3)
    YoutubeCommentsService.new(product, query: query, target: target).call
    if chat
      now = Time.current
      chat.update(last_enriched_at: now)
      chat.dashboard_card.update(last_enriched_at: now) if chat.dashboard_card.present?
    end
  end
end
