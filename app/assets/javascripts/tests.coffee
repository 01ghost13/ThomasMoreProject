# Handle clicking on thumbsup(tu), thumbsdown(td), questuion mark(qm)
$ ->
  $(document).on 'click', '#btn_tu', (evt) ->
    $.ajax 'testing/update_picture',
      type: 'GET'
      dataType: 'script'
      data: {
        value: 3,
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
        value: 1,
        progress: $('#bar_id').attr('aria-valuenow')
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Successfully changed")
$ ->
  $(document).on 'click', '#btn_qm', (evt) ->
    $.ajax 'testing/update_picture',
      type: 'GET'
      dataType: 'script'
      data: {
        value: 2,
        progress: $('#bar_id').attr('aria-valuenow')
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Successfully changed")
#Handling additional pics (Pic_back, Pic_exit)
$ ->
  $(document).on 'click', '#btn_back', (evt) ->
    $.ajax 'testing/update_picture',
      type: 'GET'
      dataType: 'script'
      data: {
        value: 0,
        progress: $('#bar_id').attr('aria-valuenow')
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Successfully changed")