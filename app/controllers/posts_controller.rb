class PostsController < ApplicationController
  def index
    @product = Product.find(params[:product_id])
    @posts = Post.where(product: @product).order(created_at: :desc)
  end
end
