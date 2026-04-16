class AssistantMessageService
  def initialize(chat, user_message: nil)
    @chat = chat
    @user_message = user_message
    @product = @chat.product
  end

  def call
    @ruby_llm_chat = RubyLLM.chat(model: "gpt-4o-mini")
    posts_db_tool = PostsDatabaseTool.new
    build_conversation_history
    if !@chat.dashboard_card.nil? && @chat.messages.count == 0
      response = @ruby_llm_chat.with_tools(posts_db_tool).with_instructions(instructions).ask("Please provide a more thourough analysis of the social media posts related to the dashboard card theme, following the detailed instructions for dashboard card analysis.")
    else
      response = @ruby_llm_chat.with_tools(posts_db_tool).with_instructions(instructions).ask(@user_message.content)
    end
    @chat.messages.create(role: "assistant", content: response.content)
    @chat.generate_title_from_first_message
  rescue StandardError => e
    Rails.logger.error "MessagesController LLM error: #{e.class}: #{e.message}"
    @chat.messages.create(
      role: "assistant",
      content: "Something went wrong while analyzing social media data. Please try again in a moment."
    )
  end

  private

  def product_context
    <<~CTX
      Product context:
      - Product ID: #{@product.id}
      - Name: #{@product.name}
      - Brand: #{@product.brand}

      IMPORTANT: whenever you call the PostsDatabaseTool, you MUST pass product_id=#{@product.id} as its `product_id` parameter. Do not invent or change this ID.
    CTX
  end

  def instructions
    if @chat.dashboard_card.present?
      [DashboardCardPrompt.content, @chat.dashboard_card.content, product_context].join("\n\n---\n\n")
    else
      [ChattingPrompt.content, product_context].join("\n\n---\n\n")
    end
  end

  def build_conversation_history
    if @user_message.nil?
      return
    else
      @chat.messages.where.not(id: @user_message.id).order(:created_at).each do |message|
        @ruby_llm_chat.add_message(role: message.role, content: message.content)
      end
    end
  end
end
