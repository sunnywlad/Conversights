class ChatsController < ApplicationController
  def new
    @chat = Chat.new
  end

  def create
    @product = Product.find(params[:product_id])
    clean_empty_chats(@product)
    @chat = Chat.new(title: Chat::DEFAULT_TITLE)
    @chat.product = @product
    @chat.dashboard_card = DashboardCard.find_by(id: params[:dashboard_card_id]) if params[:dashboard_card_id].present?
    existing_chat = Chat.find_by(product: @product, dashboard_card: @chat.dashboard_card) if @chat.dashboard_card.present?
    if existing_chat
      @chat = existing_chat
      redirect_to chat_path(@chat)
    elsif @chat.save
      DbEnrichmentJob.perform_later(@product, @chat.dashboard_card.title, chat: @chat) if @chat.dashboard_card.present?
      AssistantMessageJob.perform_later(@chat.id) if @chat.dashboard_card.present?
      redirect_to chat_path(@chat)
    else
      redirect_to product_path(@product), alert: "Erreur lors de la création du chat"
    end
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @message = Message.new
    if @chat.dashboard_card.present? && @chat.last_enriched_at.nil?
      DbEnrichmentJob.perform_later(@chat.product, @chat.dashboard_card.title, chat: @chat)
    elsif @chat.dashboard_card.present? && @chat.last_enriched_at < 1.hour.ago
      DbEnrichmentJob.perform_later(@chat.product, @chat.dashboard_card.title, chat: @chat)
    elsif !@chat.last_enriched_at.nil? && @chat.last_enriched_at < 1.hour.ago
      DbEnrichmentJob.perform_later(@chat.product, @chat.title, chat: @chat)
    end

  end

  def destroy
    @chat = current_user.chats.find(params[:id])
    # referer = request.referer
    @chat.destroy
    redirect_to product_path(@chat.product), notice: "Chat deleted."
  end

  private

  def clean_empty_chats(product)
    product.chats.left_joins(:messages).where(messages: { id:nil}).destroy_all
  end
end
