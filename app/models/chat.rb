class Chat < ApplicationRecord
  belongs_to :product
  belongs_to :dashboard_card, optional: true
  has_many :messages, dependent: :destroy

  DEFAULT_TITLE = "Welcome to Conversights"
  TITLE_PROMPT1 = <<~PROMPT
    Generate a short, descriptive, 3-to-6-word title that summarizes the user question for a chat conversation.
  PROMPT

  TITLE_PROMPT2 = <<~PROMPT
    Generate a short, descriptive, 3-to-6-word title that summarizes the theme of the dashboard card
  PROMPT

  def generate_title_from_first_message
    return unless title == DEFAULT_TITLE
    if dashboard_card.present?
      response = RubyLLM.chat.with_instructions(TITLE_PROMPT2).ask(dashboard_card.title)
    else
      first_user_message = messages.where(role: "user").order(:created_at).first
      return if first_user_message.nil?

      response = RubyLLM.chat.with_instructions(TITLE_PROMPT1).ask(first_user_message.content)
    end
    update(title: response.content)
  end
end
