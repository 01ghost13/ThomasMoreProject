class AdministratorsController < ApplicationController
  #Only for SA
  def index
    administrators = Administrator.all
    @names_admins = []
    administrators.each do |admin|
      @names_admins << Info.find(admin.info_id)
    end
  end

  #Editing page
  def edit
  end
  #Update querry
  def update
    
  end
  #Profile page
  def show
    unless Administrator.where(id: params[:id]).take.nil?
      @user = Info.find(params[:id])
    end
    #Possibly error with notfound
  end

  #Create Page
  def new
  end
  #Create querry
  def create
    
  end
end
