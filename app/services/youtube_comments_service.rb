class YoutubeCommentsService
  def initialize(product)
    @product = product
  end

  def call
    return { error: "No name or brand provided" } unless @product.name.present? && @product.brand.present?
    scraper = YoutubeScraperService.new(name: @product.name, brand: @product.brand)

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
    comments.each do |comment_data|
      Post.find_or_create_by!(
        content: comment_data,
        source: "youtube",
        product_id: @product.id
      )
    end

  end
end
