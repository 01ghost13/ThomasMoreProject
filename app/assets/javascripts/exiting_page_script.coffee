#Handle exiting page
$(window).on 'beforeunload',(evt) ->
	$.ajax {
		url: 'testing/exit',
		type: 'Post',
		async: false,
		beforeSend: (xhr) ->
			xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
	}
	undefined