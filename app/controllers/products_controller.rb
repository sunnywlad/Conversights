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
      redirect_to product_path(@product), notice: "Product created successfully.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @product = Product.find(params[:id])
    referer = request.referer
    @product.destroy

    if referer&.include?(product_path(@product))
      redirect_to products_path, notice: "Product deleted."
    else
      redirect_back_or_to products_path, notice: "Product deleted."
    end
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
