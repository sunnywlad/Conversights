class AddLastEnrichedAtToChats < ActiveRecord::Migration[7.1]
  def change
    add_column :chats, :last_enriched_at, :datetime
  end
end
