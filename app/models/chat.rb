class Chat < ApplicationRecord
  belongs_to :product
  belongs_to :dashboard_card
end
