class MessagesController < ApplicationController
    def create
      @chat = current_user.chats.find(params[:chat_id])
      @product = @chat.product

      @message = Message.new(message_params)
      @message.chat = @chat
      @message.role = "user"

      if @message.save
        @ruby_llm_chat = RubyLLM.chat(model: "gpt-4o-mini")
        youtube_tool = YoutubeTool.new
        build_conversation_history
        response = @ruby_llm_chat.with_tools(youtube_tool).with_instructions(instructions).ask(@message.content)
        @chat.messages.create(role: "assistant", content: response.content)
        @chat.generate_title_from_first_message
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
    "Product context: Name is #{@product.name} by brand : #{@product.brand}"
  end

  def instructions
    [ChattingPrompt.content, product_context].join("\n\n---\n\n")
  end

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end
end
