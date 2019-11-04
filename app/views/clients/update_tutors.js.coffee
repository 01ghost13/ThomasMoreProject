$("#mentor_selection").empty()
	.append("<%= escape_javascript(options_for_select(@mentors)) %>")
