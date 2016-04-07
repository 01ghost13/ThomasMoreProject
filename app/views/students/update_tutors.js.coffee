$("#tutor_selection").empty()
	.append("<%= escape_javascript(render(:partial => @tutors)) %>")