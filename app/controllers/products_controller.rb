class ProductsController < ApplicationController

  def index
    @products = current_user.products
  end

  def new
    @product = Product.new
  end

  def show
    @product = current_user.products.find(params[:id])
    @chats = @product.chats
    @dashboard_cards = @product.dashboard_cards || []
  end

  def create
    @product = Product.new(product_params)
    @product.user = current_user
    @product.name = @product.name.titleize.strip if @product.name.present?
    @product.brand = @product.brand.upcase.strip if @product.brand.present?
    if @product.save
      titles = ["Overall Sentiment", "Frustrations & Pain Points", "Strengths & Positive Feedback"]
      titles.each { |title| @product.dashboard_cards.create(title: title) }
      chat = @product.chats.create(title: Chat::DEFAULT_TITLE)
      redirect_to chat_path(chat), notice: "Product created — start by asking anything.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @product = current_user.products.find(params[:id])
    @product.destroy
    redirect_to products_path, notice: "Product deleted.", status: :see_other
  end

  def refresh_dashboard
    @product = Product.find(params[:id])

    DashboardRefreshService.new(@product).call
    redirect_to product_path(@product), notice: "Dashboard mis à jour !"
  end

  private

  def product_params
    params.require(:product).permit(:name, :brand)
  end
end
