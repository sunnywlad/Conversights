class Message < ApplicationRecord
  belongs_to :chat
  validates :content, presence: true, unless: -> { role == "assistant" }
  validates :role, presence: true, inclusion: { in: %w[user assistant] }

  after_create_commit :broadcast_append_to_chat

  private

  def broadcast_append_to_chat
    broadcast_append_to chat, target: "chat-messages", partial: "messages/message", locals: { message: self }
  end
end
