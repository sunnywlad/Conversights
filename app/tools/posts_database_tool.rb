class PostsDatabaseTool < RubyLLM::Tool
  description "Fetches YouTube comments for a given product. Looks into the posts database for comments, then returns the posts to the LLM."
  param :product_id, type: :integer, desc: "The integer ID of the product to fetch YouTube comments for. Must match the Product ID provided in the chat context."

  def execute(product_id:)
    product = Product.find_by(id: product_id)
    return { error: "Product not found" }.to_json unless product

    posts = product.posts.order(created_at: :desc).limit(30)
    result = {
      posts_count: posts.count,
      posts: posts.map do |post|
        {
          id: post.id,
          content: post.content,
          created_at: post.created_at
        }
      end
    }

    if result[:posts_count] == 0
      { warning: "No comments found", product_id: product_id }.to_json
    else
      result.to_json
    end
  end
end
