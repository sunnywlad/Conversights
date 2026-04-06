class Product < ApplicationRecord
  belongs_to :user
  has_many :dashboard_cards, dependent: :destroy
  has_many :chats, dependent: :destroy
end
