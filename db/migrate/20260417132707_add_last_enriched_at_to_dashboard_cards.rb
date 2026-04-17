class AddLastEnrichedAtToDashboardCards < ActiveRecord::Migration[7.1]
  def change
    add_column :dashboard_cards, :last_enriched_at, :datetime
  end
end
