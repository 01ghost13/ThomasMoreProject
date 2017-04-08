$ ->
  $(document).on 'change', '.question_selection', (evt) ->
    $.ajax window.location.pathname + '/update_image',
      type: 'GET'
      dataType: 'script'
      data: {
        picture_id: $("##{evt.target.id} option:selected").val()
        id: evt.target.id
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Dynamic pictures select OK!")
