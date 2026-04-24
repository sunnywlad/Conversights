class PostsDatabaseService
  def initialize(product, text)
    @product = product
    @text = text
  end

  def call
    return [] unless @product

    all_posts = Post.where(product_id: @product.id).order(created_at: :desc).limit(20)

    if Post.where(product_id: @product.id).where.not(embedding: nil).exists?
      begin
        embedding = RubyLLM.embed(@text)
        Post.where(product_id: @product.id).where.not(embedding: nil).nearest_neighbors(:embedding, embedding.vectors, distance: "euclidean").first(10)
      rescue StandardError => e
        Rails.logger.error "PostsDatabaseService RAG error (falling back to all posts): #{e.message}"
        all_posts
      end
    else
      all_posts
    end
  rescue StandardError => e
    Rails.logger.error "PostsDatabaseService error: #{e.message}"
    []
  end
end
