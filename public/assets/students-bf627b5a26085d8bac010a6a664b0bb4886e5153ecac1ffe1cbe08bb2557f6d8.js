(function() {
  $(function() {
    return $(document).on('change', '#administrator_selection', function(evt) {
      return $.ajax(window.location.pathname + '/update_tutors', {
        type: 'GET',
        dataType: 'script',
        data: {
          administrator_id: $("#administrator_selection option:selected").val()
        },
        error: function(jqXHR, textStatus, errorThrown) {
          return console.log("AJAX Error: " + textStatus);
        },
        success: function(data, textStatus, jqXHR) {
          return console.log("Dynamic tutors select OK!");
        }
      });
    });
  });

}).call(this);
