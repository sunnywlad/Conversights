class PostsDatabaseService
  def initialize(product, text)
    @product = product
    @text = text
  end

  def call
    return [] unless @product

    embedding = RubyLLM.embed(@text)
    Post.where(product_id: @product.id).nearest_neighbors(:embedding, embedding.vectors, distance: "euclidean").first(10)
  end
end
