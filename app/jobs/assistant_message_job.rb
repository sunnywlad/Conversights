class AssistantMessageJob < ApplicationJob
  queue_as :default

  def perform(chat_id, user_message_id: nil)
    chat = Chat.find_by(id: chat_id)
    return if chat.nil?
    user_message = chat.messages.find_by(id: user_message_id) if user_message_id.present?
    AssistantMessageService.new(chat, user_message: user_message).call
  end
end
