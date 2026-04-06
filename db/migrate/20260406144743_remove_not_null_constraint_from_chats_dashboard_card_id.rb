class RemoveNotNullConstraintFromChatsDashboardCardId < ActiveRecord::Migration[7.1]
  def change
    change_column_null :chats, :dashboard_card_id, true
  end
end
