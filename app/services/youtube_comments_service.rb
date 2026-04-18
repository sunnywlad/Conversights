class YoutubeCommentsService
  def initialize(product, query: nil, target: 3)
    @product = product
    @query = query
    @target = target
  end

  def fetch_raw
    return [] unless @product.name.present? && @product.brand.present?
    scraper = YoutubeScraperService.new(name: @product.name, brand: @product.brand, query: @query)

    raw_comments = []
    page_token = nil

    5.times do
      break if raw_comments.count >= @target
      comments, page_token = scraper.call(3, page_token: page_token)
      raw_comments += comments
      break if page_token.nil?
    end

    raw_comments
  rescue StandardError => e
    Rails.logger.error "YoutubeCommentsService fetch error: #{e.message}"
    []
  end

  def save(raw_comments)
    new_posts = []
    raw_comments.each do |comment_data|
      post = Post.find_or_create_by!(
        content: comment_data,
        source: "youtube",
        product_id: @product.id
      )
      new_posts << post if post.previously_new_record?
    end
    new_posts
  rescue StandardError => e
    Rails.logger.error "YoutubeCommentsService save error: #{e.message}"
    []
  end

  def call
    save(fetch_raw)
  rescue StandardError => e
    Rails.logger.error "YoutubeCommentsService error: #{e.message}"
    []
  end
end
