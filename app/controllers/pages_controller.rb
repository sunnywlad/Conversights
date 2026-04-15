class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :knowledge]

  def home
    if user_signed_in?
      redirect_to products_path
    end
  end

  def knowledge
  end

  def settings
  end
end
