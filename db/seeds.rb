# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Product.create!(name: "Kindle", brand: "Amazon", user_id: 1)
Titles = "Sentiment général, Thème clef 1, Thème clef 2, Thème clef 3, Frustrations exprimées, Appréciation du design"
Titles.split(", ").each do |title|
  DashboardCard.create!(title: title, product_id: 1, content: "")
end
