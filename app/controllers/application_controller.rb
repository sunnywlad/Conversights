class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :devise_controller?
  layout :set_layout

  private

  def set_layout
    devise_controller? ? "auth" : "application"
  end
end
