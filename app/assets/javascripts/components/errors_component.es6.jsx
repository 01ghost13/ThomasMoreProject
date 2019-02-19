class ErrorsComponent extends React.Component {
  render () {
    let errors_list = _.map(
      this.props.errors,
      (error, index) => this.renderError(error, index)
    );
    let errors_length = errors_list.length;
    if(errors_length === 0) { return (<div></div>); }

    return (
      <div className="row">
        <div className="col-sm-offset-2 col-sm-6">
          <div className="alert alert-danger" role="alert">
            The form contains {errors_length} {this.pluralizeError(errors_length)}.
			    <ul>
            {errors_list}
			    </ul>
		  	</div>
	  	</div>
  	</div>
    );
  }

  renderError(message, index) {
    return (
      <li key={index}>{message}</li>
    );
  }

  pluralizeError(number) {
    if(number === 1) {
      return 'error'
    }
    else {
      return 'errors'
    }
  }
}

ErrorsComponent.propTypes = {
  errors: React.PropTypes.array
};
