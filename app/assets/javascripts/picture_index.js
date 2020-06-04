$(document).on('turbolinks:load', function () {
  $("#pictures-list").css("min-height",($(window).height() + 5));
  $('#pictures-list').infiniteScroll({
    // options
    path: '/pictures.js?page={{#}}',
    append: false,
    responseType: 'text',
    history: false
  });

  $('#pictures-list').on('load.infiniteScroll', function( event, response ) {
    $('#pictures-page').append(response)
  });
});
