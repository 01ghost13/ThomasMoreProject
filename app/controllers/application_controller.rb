class ApplicationController < ActionController::Base
  include ApplicationHelper
  include TranslationModule

  protect_from_forgery with: :exception
end
