class MessagesController < ApplicationController
    SYSTEM_PROMPT = <<~PROMPT
    You are a senior consumer insights analyst.

    Your job is to analyze real social media posts and extract actionable insights for product teams.

    When given social media data, you must:
    - Summarize the overall sentiment (positive, negative, mixed)
    - Identify key themes and recurring opinions
    - Highlight notable quotes or posts
    - Give a clear, concise answer to the user's question

    To answer, you HAVE to use the 'YoutubeTool' to fetch real user comments from Youtube videos related to the product. You will use these comments as the basis for your analysis and insights.
    Always base your analysis on the provided social media data. If no data is available, say so clearly.
    Answer in the same language as the user's question, translate quotes you answer with, and give the original quote with the translation. Give clear bullet points and quote specific posts when relevant. Avoid generic statements.
  PROMPT

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
    [SYSTEM_PROMPT, product_context].join("\n\n---\n\n")
  end

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end
end
