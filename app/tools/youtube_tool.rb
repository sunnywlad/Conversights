class YoutubeTool < RubyLLM::Tool
  description "Fetches YouTube comments for a given product. First updates the database with fresh comments, then returns the stored posts to the LLM."
  param :product_id, type: Integer, description: "The ID of the product to search for on Youtube."

  def execute(product_id:)
    product = Product.find_by(id: product_id)
    return { error: "Product not found" }.to_json unless product

    result = FetchYoutubeCommentsService.new(product).call

    if result[:posts_count] == 0
      { warning: "No comments found", product_id: product_id }.to_json
    else
      result.to_json
    end
  end
end
