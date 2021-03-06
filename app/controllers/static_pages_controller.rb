class StaticPagesController < ApplicationController
  translations_for_preload %i[
    common.menu.all
    common.menu.create
    common.menu.home
    common.menu.log_out
    common.menu.my_profile
    common.menu.profile
    common.menu.settings
    entities.clients.create
    entities.clients.index
    entities.interests.index
    entities.local_administrators.create
    entities.local_administrators.index
    entities.mentors.create
    entities.mentors.index
    entities.pictures.index
    entities.tests.index
  ]

  #Log in page
  # @deprecated
  def log_in
  end

  #Page about project
  # @deprecated
  def about
    added = %w(
    All\ pictures\ should\ have\ text\ description
    Test\ should\ have\ progress\ bar
    Every\ step\ in\ the\ test\ should\ have\ 1\ picture\ instead\ of\ 3
    Test\ should\ have\ several\ navigation\ buttons:\ Exit,\ Step\ back,\ Like\ ,\ Don’t\ like
    Every\ picture\ must\ represent\ several\ fields\ of\ interests
    Administrator\ for\ managing\ users
    Profiles\ for\ clients,\ teachers
    Saving\ and\ managing\ all\ results\ of\ tests
    Information\ which\ must\ be\ saved:\ date,\ time\ of\ test,\ time\ between\ answers,\ the\ fact\ of\ reanswering
    Table\ with\ results
    Switching\ off\ client\ accounts\ instead\ of\ deleting\ from\ DB
    Creation\ of\ tests,\ interests
    Protection\ from\ spam-bots
    Confirmation\ of\ registration\ via\ e-mail
    Recovering\ of\ account\ via\ e-mail
    Highlighting\ of\ buttons
    Graph\ with\ results
    Client,\ teacher,\ admin\ search\ page
    Export\ to\ excel
    )
    will_be_added = %w(
    )
    @arr = {}
    added.each do |el|
      @arr[el] = true
    end
    will_be_added.each do |el|
      @arr[el] = false
    end
  end

  #Page with contacts
  # @deprecated
  def contacts
  end

  def home
  end
end
