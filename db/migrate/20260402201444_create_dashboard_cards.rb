class CreateDashboardCards < ActiveRecord::Migration[7.1]
  def change
    create_table :dashboard_cards do |t|
      t.string :title
      t.string :content
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
