function showPicture(evt) {
  let chart = Chartkick.charts["answer_time_chart"];
  let element = chart.chart.getElementAtEvent(evt)[0];

  if(element) {
    let pictureNumber = element._index + 1;
    $('#modal-picture').modal('show');
    let test_id = $('#modal-info').data('test_id');

    // Make api call
    $.ajax({
      url: '/tests/' + test_id + '/questions/' + pictureNumber + '/get_image',
      type: 'GET'
    })
    .done(function (data) {
      if(data.type === 'picture') {
        renderPicture(data.link);
        renderBtnEdit(data.edit_link);
      } else if (data.type === 'youtube') {
        renderYoutube(data.link);
        $('#link-edit').hide();
      }
    })
    .fail(function () {
      window.alert('Can not show picture');
      renderEmpty();
      $('#modal-picture').modal('hide');
    });
  }
}

function renderPicture(link) {
  const imgHtml = '<img src="' + link + '"/>';
  $('#thumbnail-modal').html(imgHtml)
}

function renderYoutube(link) {
  const ytHtml = '<iframe is width="100%" height="345" src="' + link + '" frameBorder="0" allowFullScreen="" />';
  $('#thumbnail-modal').html(ytHtml);
}

function renderBtnEdit(edit_link) {
  let $link_edit = $('#link-edit');

  $link_edit.show();
  $link_edit.attr('href', edit_link);
}

function renderEmpty() {
  $('#thumbnail-modal').html('');
  $('#link-edit').hide();
}

$('turbolinks:load', function () {
  $('#answer_time_chart > canvas').on('click', showPicture);
});
