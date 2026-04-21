class PostsDatabaseService
  def initialize(product, text)
    @product = product
    @text = text
  end

  def call
    return [] unless @product
    return [] unless Post.where(product_id: @product.id).where.not(embedding: nil).exists?

    embedding = RubyLLM.embed(@text)
    Post.where(product_id: @product.id).where.not(embedding: nil).nearest_neighbors(:embedding, embedding.vectors, distance: "euclidean").first(10)
  rescue StandardError => e
    Rails.logger.error "PostsDatabaseService error: #{e.message}"
    []
  end
end
