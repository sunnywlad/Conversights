class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :source
      t.string :content
      t.date :date
      t.references :product, null: false, foreign_key: true
      t.string :keywords
      t.integer :appreciation
      t.integer :value

      t.timestamps
    end
  end
end
