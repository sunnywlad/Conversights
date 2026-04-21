class AddEmbeddingToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :embedding, :vector, limit: 1536
  end
end
