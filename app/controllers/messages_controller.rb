class MessagesController < ApplicationController
  def create
    @chat = current_user.chats.find(params[:chat_id])
    @product = @chat.product

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      begin
        @ruby_llm_chat = RubyLLM.chat(model: "gpt-4o-mini")
        youtube_tool = YoutubeTool.new
        build_conversation_history
        response = @ruby_llm_chat.with_tools(youtube_tool).with_instructions(instructions).ask(@message.content)
        @chat.messages.create(role: "assistant", content: response.content)
        @chat.generate_title_from_first_message
      rescue StandardError => e
        Rails.logger.error "MessagesController LLM error: #{e.class}: #{e.message}"
        @chat.messages.create(
          role: "assistant",
          content: "Something went wrong while analyzing social media data. Please try again in a moment."
        )
      end
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def product_context
    <<~CTX
      Product context:
      - Product ID: #{@product.id}
      - Name: #{@product.name}
      - Brand: #{@product.brand}

      IMPORTANT: whenever you call the YoutubeTool, you MUST pass product_id=#{@product.id} as its `product_id` parameter. Do not invent or change this ID.
    CTX
  end

  def instructions
    [ChattingPrompt.content, product_context].join("\n\n---\n\n")
  end

  def build_conversation_history
    @chat.messages.where.not(id: @message.id).order(:created_at).each do |message|
      @ruby_llm_chat.add_message(role: message.role, content: message.content)
    end
  end
end
