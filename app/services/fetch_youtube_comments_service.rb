class FetchYoutubeCommentsService
  def initialize(product)
    @product = product
  end

  def call
    YoutubeCommentsService.new(@product).call

    posts = Post.where(product_id: @product.id)
                .order(created_at: :desc)
                .limit(30)

    {
      product_id: @product.id,
      product_name: @product.name,
      brand: @product.brand,
      posts_count: posts.count,
      posts: posts.map do |post|
        {
          id: post.id,
          content: post.content,
          created_at: post.created_at
        }
      end
    }
  end
end
