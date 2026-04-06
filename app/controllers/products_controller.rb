class ProductsController < ApplicationController

  def index
    @products = current_user.products
  end

  def show
    @product = current_user.products.find(params[:id])
    @dashboard_cards = @product.dashboard_cards
  end
end
