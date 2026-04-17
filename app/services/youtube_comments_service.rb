class YoutubeCommentsService
  def initialize(product, query: nil, target: 15)
    @product = product
    @query = query
    @target = target
  end

  def call
    return [] unless @product.name.present? && @product.brand.present?
    scraper = YoutubeScraperService.new(name: @product.name, brand: @product.brand, query: @query)

    new_count = 0
    page_token = nil
    max_iterations = 5

    max_iterations.times do
      break if new_count >= @target
      comments, page_token = scraper.call(3, page_token: page_token)
      new_count += store_comments(comments)
      break if page_token.nil?
    end

  rescue StandardError => e
    Rails.logger.error "YoutubeCommentsFetcher error: #{e.message}"
    { error: "Failed to fetch Youtube comments: #{e.message}" }
  end

  private

  def store_comments(comments)
    posts_to_be_embedded = []
    comments.each do |comment_data|
      post = Post.find_or_create_by!(
        content: comment_data,
        source: "youtube",
        product_id: @product.id
      )
      posts_to_be_embedded << post if post.previously_new_record?
    end
    posts_to_be_embedded.each_with_index do |post, index|
      SetEmbeddingJob.set(wait: 3 * index.seconds).perform_later(post)
    end
    posts_to_be_embedded.count
  end
end
