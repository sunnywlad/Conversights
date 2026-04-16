class MessagesController < ApplicationController
  def create
    @chat = current_user.chats.find(params[:chat_id])
    @product = @chat.product

    @user_message = Message.new(message_params)
    @user_message.chat = @chat
    @user_message.role = "user"

    if @user_message.save
      AssistantMessageJob.perform_later(@chat.id, user_message_id: @user_message.id)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_path(@chat) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_message_area", partial: "messages/form", locals: { chat: @chat, message: @user_message }) }
        format.html { render "chats/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
