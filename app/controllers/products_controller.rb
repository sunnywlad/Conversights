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
    @dashboard_cards = @product.dashboard_cards.order(:created_at) || []
  end

  def create
    @product = Product.new(product_params)
    @product.user = current_user
    @product.name = @product.name.titleize.strip if @product.name.present?
    @product.brand = @product.brand.upcase.strip if @product.brand.present?
    if @product.save
      titles = "Key Theme 1, Key Theme 2, Key Theme 3, Frustrations & Pain Points, Strengths & Positive Feedback, Suggested Improvements".split(", ")
      titles.each { |title| @product.dashboard_cards.create(title: title) }
      DashboardRefreshJob.perform_later(@product.id)
      redirect_to products_path, notice: "Product created successfully, dashboard being updated !", status: :see_other
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
    @product = current_user.products.find(params[:id])
    clean_empty_chats(@product)

    DashboardRefreshJob.perform_later(@product.id)
    redirect_to product_path(@product), notice: "Dashboard being updated !"
  end

  private

  def product_params
    params.require(:product).permit(:name, :brand)
  end

  def clean_empty_chats(product)
    product.chats.left_joins(:messages).where(messages: { id:nil}).destroy_all
  end
end
