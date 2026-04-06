class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]
  layout :set_layout

  def home
    redirect_to products_path if user_signed_in?
  end

  private

  def set_layout
    if action_name == 'home'
      'home'
    else
      devise_controller? ? "auth" : "application"
    end
  end

end
