$ ->
  $(document).on 'change', '.question_selection', (evt) ->
    url = window.location.pathname
    url += '/edit' if /tests\/\d+\/?$/.test(url)
    url += '/new' if /tests\/?$/.test(url)
    $.ajax url + '/update_image',
      type: 'GET'
      dataType: 'script'
      data: {
        picture_id: $("##{evt.target.id} option:selected").val()
        event_id: evt.target.id
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Dynamic pictures select OK!")
