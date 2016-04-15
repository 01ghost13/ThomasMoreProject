class TestsController < ApplicationController
  
  def new
  end

  def edit
  end

  def index
  end
  def exit
    #if has answers - saving
    #redirecting to result
  end
  def update_picture
    #Writing result
    #Changing variables
    ##Finding next pic name
    ##if was last pic saving and redirecting to result
    @log = params[:value]
    @i = 2
    @progress_bar_value = params[:progress].to_i + 10
    @description = "This is another descr"
    @image = "1. Semi-industrieel werk (2).jpg"
    respond_to do |format|
       format.js {}
    end
  end
  
  def testing
    @log = ""
    @progress_bar_value = 0
    #Loading test
    #test = Test.find(params[:id])
    @description = "This is a description"
    @i = 1
  end
end
