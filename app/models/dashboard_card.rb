class DashboardCard < ApplicationRecord
  belongs_to :product
  has_many :chats, dependent: :nullify
end
