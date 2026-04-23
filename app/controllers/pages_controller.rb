class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :knowledge]
  layout "home", only: :home

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
