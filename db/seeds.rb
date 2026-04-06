# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "clearing existing data..."
Product.destroy_all
DashboardCard.destroy_all
Chat.destroy_all
Message.destroy_all
puts "creating seed data..."
Product.create!(name: "Kindle", brand: "Amazon", user_id: 1)
titles = "Sentiment général, Thème clef 1, Thème clef 2, Thème clef 3, Frustrations exprimées, Appréciation du design".split(", ")
Product.all.each do |product|
  titles.each { |title| DashboardCard.create!(title: title, product_id: product.id, content: "") }
end
puts "#{Product.count} products created with #{DashboardCard.count} dashboard cards."
puts "seeding complete =D"
