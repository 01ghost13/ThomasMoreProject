#Handle exiting page

$(window).on 'beforeunload',(evt) ->
	$.ajax {
		beforeSend: (xhr) ->
			xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')),
			url: 'testing/exit',
    		type: 'Post'
	}
	return null