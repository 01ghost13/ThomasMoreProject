class SearchController < ApplicationController
  def search_result
  end
  def submit_search
    query = params[:search]
    render :search_result
  end
end
