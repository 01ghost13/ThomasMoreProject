class ResultOfTestsController < ApplicationController
  #TODO: Add check of logging
  #TODO: Add group stats
  def edit
    #Loading res info
    @result = ResultOfTest.find(params[:result_id])
    @user = @result
  end
  def update
    #Loading res info
    @result = ResultOfTest.find(params[:result_id])
    @user = @result
    if @result.update(result_params)
      redirect_to(student_result_of_test_path(params[:student_id],params[:result_id]))
      flash[:success] = "Update Complete"
    else
      render :edit
    end
  end

  def show
    #Loading result
    result = ResultOfTest.find(params[:result_id])
    #Loading q results
    q_res  = result.question_results
    q_test = Question.where(test_id: result.test_id)
    #Loading all interests
    interests = {}
    interests_max = {}
    timestamps = []
    #Making array of interests
    #debugger
    q_res.each do |r|
      #debugger
      timestamps << r.show
      #debugger
      #Related interests for result
      related_i = []
      q_test.each do |q|
        related_i = q.picture.related_interests if q.number == r.number
      end
      #debugger
      related_i.each_key do |interest|
        #debugger
        if interests[interest].nil?
          #debugger
          interests_max[interest] = related_i[interest]
          interests[interest] = 0
          interests[interest] = related_i[interest] if r.was_checked == 3 #Was thumbs up
        else
          #debugger
          interests_max[interest] += related_i[interest]
          interests[interest] += related_i[interest] if r.was_checked == 3
          #interests[i] -= related_i[i] if r.was_checked == 1  
        end
      end
    end
    #Sorting
    @list_interests = interests.to_a.sort{ |x,y| y[1] - x[1]}
    @list_timestamps = timestamps
    @list_interests_max = interests_max
    #Making list of timing
  end
  
  def index
    
  end
  private
    def result_params
      debugger
      params.require(:result_of_test).permit(question_results_attributes: [:was_checked,:id])
    end
end
