class AddSentimentToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :sentiment_score, :decimal
    add_column :products, :sentiment_label, :string
  end
end
