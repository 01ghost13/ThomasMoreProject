(function() {
  $(function() {
    return $(document).on('change', '.question_selection', function(evt) {
      var url;
      url = window.location.pathname;
      if (/tests\/\d+\/?$/.test(url)) {
        url += '/edit';
      }
      if (/tests\/?$/.test(url)) {
        url += '/new';
      }
      return $.ajax(url + '/update_image', {
        type: 'GET',
        dataType: 'script',
        data: {
          picture_id: $("#" + evt.target.id + " option:selected").val(),
          event_id: evt.target.id
        },
        error: function(jqXHR, textStatus, errorThrown) {
          return console.log("AJAX Error: " + textStatus);
        },
        success: function(data, textStatus, jqXHR) {
          return console.log("Dynamic pictures select OK!");
        }
      });
    });
  });

}).call(this);
