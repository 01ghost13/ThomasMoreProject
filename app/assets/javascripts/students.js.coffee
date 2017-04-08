# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $(document).on 'change', '#administrator_selection', (evt) ->
    url = window.location.pathname
    url += '/edit' if /students\/\d+\/?$/.test(url)
    url += '/new' if /students\/?$/.test(url)
    $.ajax url + '/update_tutors',
      type: 'GET'
      dataType: 'script'
      data: {
        administrator_id: $("#administrator_selection option:selected").val()
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Dynamic tutors select OK!")