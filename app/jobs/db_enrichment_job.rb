class DbEnrichmentJob < ApplicationJob
  queue_as :default

  def perform(product, query, chat: nil, target: 3)
    new_posts = YoutubeCommentsService.new(product, query: query, target: target).call
    new_posts.each_with_index do |post, index|
      SetEmbeddingJob.set(wait: 1.minute + (index * 3).seconds).perform_later(post)
    end
    if chat
      now = Time.current
      chat.update(last_enriched_at: now)
      chat.dashboard_card.update(last_enriched_at: now) if chat.dashboard_card.present?
    end
  end
end
