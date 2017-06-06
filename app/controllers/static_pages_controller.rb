class StaticPagesController < ApplicationController
  def log_in

  end

  def about
    added = %w(
    All\ pictures\ should\ have\ text\ description
    Test\ should\ have\ progress\ bar
    Every\ step\ in\ the\ test\ should\ have\ 1\ picture\ instead\ of\ 3
    Test\ should\ have\ several\ navigation\ buttons:\ Exit,\ Step\ back,\ Like\ ,\ Don’t\ like
    Every\ picture\ must\ represent\ several\ fields\ of\ interests
    Administrator\ for\ managing\ users
    Profiles\ for\ students,\ teachers
    Saving\ and\ managing\ all\ results\ of\ tests
    Information\ which\ must\ be\ saved:\ date,\ time\ of\ test,\ time\ between\ answers,\ the\ fact\ of\ reanswering
    Table\ with\ results
    Switching\ off\ student\ accounts\ instead\ of\ deleting\ from\ DB
    Creation\ of\ tests,\ interests
    Protection\ from\ spam-bots
    Confirmation\ of\ registration\ via\ e-mail
    Recovering\ of\ account\ via\ e-mail
    )
    will_be_added = %w(
    Graph\ with\ results
    Highlighting\ of\ buttons
    Student\ and\ teacher\ search\ page
    Export\ to\ excel
    Sound\ description\ of\ images,\ for\ people\ with\ poor\ eyesight
    )
    @arr = {}
    added.each do |el|
      @arr[el] = true
    end
    will_be_added.each do |el|
      @arr[el] = false
    end
  end

  def contacts

  end
end
