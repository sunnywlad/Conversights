class DashboardRefreshJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    product = Product.find_by(id: product_id)
    return unless product
    DashboardRefreshService.new(product).call
  end
end
