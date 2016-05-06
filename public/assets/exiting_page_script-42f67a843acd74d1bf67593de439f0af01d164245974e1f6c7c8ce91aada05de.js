(function() {
  $(window).on('beforeunload', function(evt) {
    $.ajax({
      url: 'testing/exit',
      type: 'Post',
      async: false,
      beforeSend: function(xhr) {
        return xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      }
    });
    return void 0;
  });

}).call(this);
