# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $(document).on 'click', '#btn_tu', (evt) ->
    $.ajax 'testing/update_picture',
      type: 'GET'
      dataType: 'script'
      data: {
        value: "tu",
        progress: $('#bar_id').attr('aria-valuenow')
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Successfully changed")
$ ->
  $(document).on 'click', '#btn_td', (evt) ->
    $.ajax 'testing/update_picture',
      type: 'GET'
      dataType: 'script'
      data: {
        value: "td",
        progress: $('#bar_id').attr('aria-valuenow')
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Successfully changed")
$ ->
  $(document).on 'click', '#btn_td', (evt) ->
    $.ajax 'testing/update_picture',
      type: 'GET'
      dataType: 'script'
      data: {
        value: "qm",
        progress: $('#bar_id').attr('aria-valuenow')
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Successfully changed")
$ ->
  $(document).on 'click', '#btn_back', (evt) ->
    $.ajax 'testing/update_picture',
      type: 'GET'
      dataType: 'script'
      data: {
        value: "back",
        progress: $('#bar_id').attr('aria-valuenow')
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Successfully changed")
$ ->
  $(document).on 'click', '#btn_exit', (evt) ->
    $.ajax 'testing/exit',
      type: 'GET'
      dataType: 'script'
      data: {
        value: "exit",
        progress: $('#bar_id').attr('aria-valuenow')
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Successfully changed")