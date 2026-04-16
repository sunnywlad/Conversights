class MessagesController < ApplicationController
  def create
    @chat = current_user.chats.find(params[:chat_id])
    @product = @chat.product

    @user_message = Message.new(message_params)
    @user_message.chat = @chat
    @user_message.role = "user"

    if @user_message.save
      AssistantMessageJob.perform_later(@chat.id, user_message_id: @user_message.id)
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
