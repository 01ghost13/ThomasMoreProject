$(function () {

  function sendRoles(roles_array) {
    $.ajax({
      url: '/test_availabilities/batch_update',
      method: 'PATCH',
      data: {
        payload: roles_array
      }
    })
    .done(function (data, textStatus, jqXHR) {
      $('.msg').html('');
      roles_array.forEach(function (role) {
        $('.msg_' + role.test_availabilities.id).html(data['msg']);
      });
    })
    .fail(function (jqXHR, textStatus, errorThrown) {
      alert('Rule was not saved');
    });
  }

  function checkboxChooserConstructor(source_target_data, checkbox_data_id) {
    return function(e) {
      let user_id = $(e.target).data(source_target_data);

      let role_ids = getRoleIds($(checkbox_data_id + user_id));

      sendRoles(role_ids);
    }
  }

  function getRoleIds($array_of_checkboxes) {
    return $.map($array_of_checkboxes, function ($el) {
      let $checkbox = $($el);
      let role_id = $checkbox.data('role-id');
      $checkbox[0].checked = !$checkbox[0].checked;

      return {
        test_availabilities: {
          available: $checkbox[0].checked,
          id: role_id
        }
      };
    });
  }

  $('.role-checkbox').on('click', function (e) {
    let role_id = $(e.target).data('role-id');

    sendRoles([{
      test_availabilities: {
        available: e.target.checked,
        id: role_id
      }
    }]);
  });


  $('.table-row').on('click', checkboxChooserConstructor('user-id', '.user_'));

  $('.table-header').on('click', checkboxChooserConstructor('test-id', '.test_'));
});
