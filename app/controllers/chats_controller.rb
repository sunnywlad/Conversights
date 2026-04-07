class ChatsController < ApplicationController
  def new
    @chat = Chat.new
  end

  def create
    @product = Product.find(params[:product_id])
    @chat = Chat.new(title: Chat::DEFAULT_TITLE)
    @chat.product = @product
    @chat.save!
    if @chat.save
      redirect_to chat_path(@chat)
    else
      redirect_to product_path(@product), alert: "Erreur lors de la création du chat"
    end
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @message = Message.new
  end

  def destroy
    @chat = current_user.chats.find(params[:id])
    # referer = request.referer
    @chat.destroy
    redirect_to product_path(@chat.product), notice: "Chat deleted."
    # # if referer&.include?(chat_path(@chat))
    #   redirect_to product_path(@chat.product), notice: "Chat deleted."
    # # else
    #   redirect_back_or_to product_path(@chat.product), notice: "Chat deleted."
    # end
  end
end
