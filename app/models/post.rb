class Post < ApplicationRecord
  belongs_to :product

  has_neighbors :embedding
end
