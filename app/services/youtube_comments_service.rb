class YoutubeCommentsService
  def initialize(product, query: nil, order: 'relevance')
    @product = product
    @query = query
    @order = order
  end

  def call
    return { error: "No name or brand provided" } unless @product.name.present? && @product.brand.present?
    scraper = YoutubeScraperService.new(name: @product.name, brand: @product.brand, query: @query, order: @order)

    data = scraper.call(10).flatten
    data = data.first(20)

    puts "📤 DATA ENVOYÉE AU LLM : #{data.inspect}"

    store_comments(data)

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
  end
end
