$(function () {
  $('#test_select').on('change', function (e) {
    let test_id = e.target.value;

    window.location.href = window.location.origin + window.location.pathname + '?test_id=' + test_id
  });
});
