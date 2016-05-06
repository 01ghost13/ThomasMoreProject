(function() {
  $(function() {
    return $(document).on('click', '#btn_tu', function(evt) {
      return $.ajax('testing/update_picture', {
        type: 'GET',
        dataType: 'script',
        data: {
          value: 3,
          progress: $('#bar_id').attr('aria-valuenow')
        },
        error: function(jqXHR, textStatus, errorThrown) {
          return console.log("AJAX Error: " + textStatus);
        },
        success: function(data, textStatus, jqXHR) {
          return console.log("Successfully changed");
        }
      });
    });
  });

  $(function() {
    return $(document).on('click', '#btn_td', function(evt) {
      return $.ajax('testing/update_picture', {
        type: 'GET',
        dataType: 'script',
        data: {
          value: 1,
          progress: $('#bar_id').attr('aria-valuenow')
        },
        error: function(jqXHR, textStatus, errorThrown) {
          return console.log("AJAX Error: " + textStatus);
        },
        success: function(data, textStatus, jqXHR) {
          return console.log("Successfully changed");
        }
      });
    });
  });

  $(function() {
    return $(document).on('click', '#btn_qm', function(evt) {
      return $.ajax('testing/update_picture', {
        type: 'GET',
        dataType: 'script',
        data: {
          value: 2,
          progress: $('#bar_id').attr('aria-valuenow')
        },
        error: function(jqXHR, textStatus, errorThrown) {
          return console.log("AJAX Error: " + textStatus);
        },
        success: function(data, textStatus, jqXHR) {
          return console.log("Successfully changed");
        }
      });
    });
  });

  $(function() {
    return $(document).on('click', '#btn_back', function(evt) {
      return $.ajax('testing/update_picture', {
        type: 'GET',
        dataType: 'script',
        data: {
          value: 0,
          progress: $('#bar_id').attr('aria-valuenow')
        },
        error: function(jqXHR, textStatus, errorThrown) {
          return console.log("AJAX Error: " + textStatus);
        },
        success: function(data, textStatus, jqXHR) {
          return console.log("Successfully changed");
        }
      });
    });
  });

}).call(this);
