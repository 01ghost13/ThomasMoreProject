class TestForm extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      ...props.test,
      errors: {
        full_messages: [],
        fields: []
      }
    };

    //Bindings
    this.sendForm = this.sendForm.bind(this);
    this.nameChanged = this.nameChanged.bind(this);
    this.versionChanged = this.versionChanged.bind(this);
    this.descriptionChanged = this.descriptionChanged.bind(this);
    this.addQuestion = this.addQuestion.bind(this);
  }

  nameChanged(event) {
    this.setState({...this.state, name: event.target.value});
  }

  versionChanged(event) {
    this.setState({...this.state, version: event.target.value});
  }

  descriptionChanged(event) {
    this.setState({...this.state, description: event.target.value});
  }

  pictureChanged(event, index) {
    let new_state = {...this.state};
    new_state.questions_attributes[index].picture_id = parseInt(event.target.value);
    this.setState(new_state);
  }

  removePicture(index) {
    let new_state = {...this.state};
    if (new_state.questions_attributes[index].id) {
      new_state.questions_attributes[index]._destroy = true;
    } else {
      new_state.questions_attributes.splice(index, 1);
    }
    new_state = this.recountOrder(new_state);
    this.setState(new_state);
  }

  recountOrder(state) {
    let new_state = {...state};

    for (let i = 0; i < new_state.questions_attributes.length; i++) {
      if(new_state.questions_attributes[i]._destroy !== true) {
        new_state.questions_attributes[i].number = i + 1;
      }
    }
    return new_state;
  }

  addQuestion() {
    let new_state = {...this.state};
    new_state.questions_attributes.push({...this.defaultQuestion()});
    this.setState(new_state);
  }

  defaultQuestion() {
    let pictures = _.filter(this.state.questions_attributes,
      (question) => question._destroy !== true
    );

    return {
      id: undefined,
      picture_id: _.get(this.props.picture_list[0], 'id', ''),
      number: pictures.length + 1
    };
  }

  getPictureLinkById(picture_id) {
    return _.find(this.props.picture_list, (picture) => picture.id === picture_id);
  }

  request() {
    if (this.props.form_type === 'new') {
      return { url:'/tests', method: 'post' };
    }
    let url = '/tests/:id/'.replace(':id', this.props.test.id);
    return { url: url, method: 'patch' };
  }

  sendForm() {
    let req = this.request();

    $.ajax({
      url: req.url,
      method: req.method,
      dataType: "json",
      data: {
        test: {
          ...this.state
        }
      },
      success: function (response, status, jqxhr) {
        window.location.replace("/tests");
      },
      error: (response, status, jqxhr) => {
        this.setState({errors: response.responseJSON.response});
      }
    });
  }

  renderName() {
    return(
      <div className="row col-sm-offset-2 form-group">
        <label className="col-sm-2 control-label">Name</label>
        <div className="col-sm-4">
          <input className="form-control"
                 type="text"
                 value={this.state.name}
                 onChange={this.nameChanged}
                 placeholder="Name"
          />
        </div>
      </div>
    );
  }

  renderVersion() {
    return(
      <div className="row col-sm-offset-2 form-group">
        <label className="col-sm-2 control-label">Version</label>
        <div className="col-sm-4">
          <input className="form-control"
                 type="text"
                 value={this.state.version}
                 onChange={this.versionChanged}
                 placeholder="Version"
          />
        </div>
      </div>
    );
  }

  renderDescription() {
    return(
      <div className="row col-sm-offset-2 form-group">
        <label className="col-sm-2 control-label">Description</label>
        <div className="col-sm-4">
          <input className="form-control"
                 type="text"
                 value={this.state.description}
                 onChange={this.descriptionChanged}
                 placeholder="Description"
          />
        </div>
      </div>
    );
  }

  renderQuestions() {
    let question_list = _.map(
      this.state.questions_attributes,
      (question, index) => this.renderQuestion(question, index)
    );

    return(
      <div id="questions">
        {question_list}
        <div className="row col-sm-offset-7 form-group">
          <a className="btn btn-primary col-sm-4"
             onClick={this.addQuestion}
          >
            Add question
          </a>
        </div>
      </div>
    );
  }

  pictureOption(picture) {
    return (
      <option key={picture.id}
              value={picture.id}
      >
        {picture.name}
      </option>
    );
  }

  renderQuestion(question, index) {
    if(question._destroy) {
      return '';
    }

    let picture_preview = _.get(this.getPictureLinkById(question.picture_id), 'preview', '#');
    let picture_options = _.map(this.props.picture_list, (picture) => this.pictureOption(picture));
    return (
      <div key={index}
           className="row col-sm-offset-2 form-group"
      >
        <div className="row col-sm-offset-3"
             style={{marginBottom: '20px'}}
        >
          <img src={picture_preview}
               className="img-responsive img-rounded"
          />
        </div>

        <div className="row form-group">
          <label className="col-sm-2 control-label">
            Picture
          </label>
          <div className="col-sm-4">
            <select className="form-control"
                    value={question.picture_id}
                    onChange={(e) => this.pictureChanged(e, index)}
            >
              {picture_options}
            </select>
          </div>
          <div className="col-sm-4">
            <a className="btn btn-warning"
               onClick={() => this.removePicture(index)}
            >
              Remove question
            </a>
          </div>
        </div>
        <hr/>
      </div>
    );
  }

  renderButton() {
    return (
      <div className="row col-sm-offset-2 form-group">
        <div className="col-sm-offset-2 col-sm-4">
          <a className="btn btn-primary col-sm-6"
                  onClick={this.sendForm}
          >
            Confirm
          </a>
        </div>
      </div>
    );
  }

  render() {
    return (
      <div id="form">
        <ErrorsComponent errors={ this.state.errors.full_messages } />
        {this.renderName()}

        {this.renderVersion()}

        {this.renderDescription()}

        {this.renderQuestions()}

        {this.renderButton()}
      </div>
    );
  }
}

TestForm.propTypes = {
  test: React.PropTypes.shape({
    id: React.PropTypes.number,
    description: React.PropTypes.string,
    name: React.PropTypes.string,
    version: React.PropTypes.string,
    questions_attributes: React.PropTypes.array
  }),
  picture_list: React.PropTypes.array,
  form_type: React.PropTypes.string
};

TestForm.defaultProps = {
  test: {
    id: '',
    description: '',
    name: '',
    version: '',
    questions_attributes: []
  },
  picture_list: [],
  form_type: 'create'
};
