class ApplicationController < ActionController::Base
  include ApplicationHelper
  include TranslationHelper

  protect_from_forgery with: :exception
end
