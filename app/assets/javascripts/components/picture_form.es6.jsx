class PictureForm extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      ...props.picture,
      errors: {
        full_messages: [],
        fields: []
      }
    };

    //Bindings
    this.descriptionChanged = this.descriptionChanged.bind(this);
    this.sendForm = this.sendForm.bind(this);
    this.addInterest = this.addInterest.bind(this);
    this.imageChanged = this.imageChanged.bind(this);
    this.audioChanged = this.audioChanged.bind(this);
  }

  defaultInterest() {
    return {
      id: undefined,
      interest_id: _.get(this.props.interests_list[0], 'id', ''),
      earned_points: 1
    };
  };

  descriptionChanged(event) {
    this.setState({...this.state, description: event.target.value});
  }

  imageChanged(event) {
    this.setState({
      ...this.state,
      image: event.target.files[0]
    });
  }

  audioChanged(event) {
    this.setState({
      ...this.state,
      audio: event.target.files[0]
    });
  }

  selectChanged(event, index) {
    let new_state = {...this.state};
    new_state.picture_interests_attributes[index].interest_id = parseInt(event.target.value);
    this.setState({...new_state});
  }

  earnedPointsChanged(event, index) {
    let new_state = {...this.state};
    new_state.picture_interests_attributes[index].earned_points = parseInt(event.target.value);
    this.setState({...new_state});
  }

  request() {
    if (this.props.form_type === 'new') {
      return { url:'/pictures', method: 'post' };
    }
    let url = '/pictures/:id/'.replace(':id', this.props.picture.id);
    return { url: url, method: 'patch' };
  }

  formData() {
    let fd = new FormData();
    let form_keys = {
      id: '',
      description: '',
      image: null,
      audio: null
    };

    for(let [key, value] of Object.entries(form_keys)) {
      if(this.state[key] !== '' && this.state[key] !== undefined) {
        fd.append('picture[' + key + ']', this.state[key]);
      }
    }

    let i = 0;

    for(let attributes of this.state['picture_interests_attributes']) {
      if(attributes.id !== undefined) {
        fd.append('picture[picture_interests_attributes][' + i + '][id]', attributes.id);
      }
      if(attributes._destroy !== undefined) {
        fd.append('picture[picture_interests_attributes][' + i + '][_destroy]', attributes._destroy);
      }
      fd.append('picture[picture_interests_attributes][' + i + '][interest_id]', attributes.interest_id);
      fd.append('picture[picture_interests_attributes][' + i + '][earned_points]', attributes.earned_points);
      i += 1
    }

    return fd;
  }

  sendForm(event, index) {
    let req = this.request();

    $.ajax({
      url: req.url,
      method: req.method,
      processData: false,
      contentType: false,
      data: this.formData(),
      success: function (response, status, jqxhr) {
        window.location.replace("/pictures");
      },
      error: (response, status, jqxhr) => {
        this.setState({errors: response.responseJSON.response});
      }
    });

  }

  addInterest() {
    let new_state = {...this.state};
    new_state.picture_interests_attributes.push({...this.defaultInterest()});
    this.setState(new_state);
  }

  removeInterest(index) {
    let new_state = {...this.state};
    if (new_state.picture_interests_attributes[index].id) {
      new_state.picture_interests_attributes[index]._destroy = true;
    } else {
      new_state.picture_interests_attributes.splice(index, 1);
    }
    this.setState({...new_state});
  }

  renderDescription() {
    return (
      <div className="row col-sm-offset-2 form-group">
        <label className="col-sm-2 control-label">{tf('entities.pictures.fields.description')}</label>
        <div className="col-sm-4">
          <input className="form-control"
                 type="text"
                 value={this.state.description || ''}
                 onChange={this.descriptionChanged}
                 placeholder={tf('entities.pictures.fields.description')}
          />
        </div>
      </div>
    );
  }

  renderPicture() {
    return(
      <div>
        <div className="row col-sm-offset-2 form-group">
          <label className="col-sm-2 control-label">{tf('entities.pictures.fields.image')}</label>
          <div className="col-sm-4">
            <input type="file"
                   className="form-control"
                   accept="image/*"
                   id="image_upload"
                   onChange={this.imageChanged}
            />
          </div>
        </div>
        {this.renderPicturePreview()}
      </div>
    );
  }

  renderPicturePreview() {
    if (this.props.picture_preview) {
      return(
        <div className="row col-sm-offset-4 form-group">
          <img src={this.props.picture_preview} />
        </div>
      );
    } else {
      return '';
    }
  }

  renderAudio() {
    return(
      <div>
        <div className="row col-sm-offset-2 form-group">
          <label className="col-sm-2 control-label">{'Audio description'}</label>
          <div className="col-sm-4">
            <input type="file"
                   className="form-control"
                   accept="audio/*"
                   id="audio_upload"
                   onChange={this.audioChanged}
            />
          </div>
        </div>
        {this.renderAudioPreview()}
      </div>
    );
  }

  renderAudioPreview() {
    if(this.props.audio_preview === '') { return ''; }
    return(
      <div className="row col-sm-offset-4 form-group">
        <audio controls="controls"
               src={this.props.audio_preview}
        ></audio>
      </div>
    );
  }

  renderInterests() {
    let interest_list = _.map(
      this.state.picture_interests_attributes,
      (picture_interest, index) => this.renderInterest(picture_interest, index)
    );

    return(
      <div id="interests_form">
        {interest_list}
        <div className="row col-sm-offset-2 form-group">
          <div className="row col-sm-offset-6 col-sm-2">
            <a className="btn btn-primary"
               onClick={this.addInterest}
            >
              {tf('entities.pictures.add_interest')}
            </a>
          </div>
        </div>
      </div>
    );
  }

  interestOptions(interest) {
    return (
      <option key={interest.id} value={interest.id}>{interest.name}</option>
    );
  }

  renderInterest(picture_interest, index) {
    if(picture_interest === undefined || picture_interest.length === 0 || picture_interest._destroy) {
      return '';
    }

    let options = _.map(this.props.interests_list, (interest) => this.interestOptions(interest));
    return(
      <div key={index} className="row col-sm-offset-2 form-group nested-fields">
        <label className="col-sm-2 control-label">{tf('entities.interests.interest')}</label>
        <input type="hidden" value={picture_interest.id} />
        <div className="col-sm-4">
          <select className="form-control"
                  value={picture_interest.interest_id}
                  onChange={(e) => this.selectChanged(e, index)}
          >
            {options}
          </select>
        </div>
        <div className="col-sm-2">
          <input type="number"
                 min={1}
                 max={5}
                 step={1}
                 id="earned_points"
                 placeholder={tf('entities.pictures.fields.weight')}
                 className="form-control"
                 value={picture_interest.earned_points}
                 onChange={(e) => this.earnedPointsChanged(e, index)}
          />
        </div>
        <div className="col-sm-4">
          <a className="btn btn-warning"
             onClick={() => this.removeInterest(index)}
          >
            {tf('entities.pictures.remove_interest')}
          </a>
        </div>
      </div>
    );
  }

  render() {
    return (
      <div id="form">
        <ErrorsComponent errors={ this.state.errors.full_messages } />

        {this.renderDescription()}

        {this.renderPicture()}

        {this.renderAudio()}

        {this.renderInterests()}

        <div className="row col-sm-offset-2 form-group">
          <div className="col-sm-offset-2 col-sm-2">
            <button className="btn btn-primary"
                    onClick={this.sendForm}
            >
              {tf('common.forms.confirm')}
            </button>
          </div>
        </div>
      </div>
    );
  }
}

PictureForm.propTypes = {
  picture: React.PropTypes.shape({
    description: React.PropTypes.string,
    picture_interests_attributes: React.PropTypes.array
  }),
  interests_list: React.PropTypes.array,
  picture_preview: React.PropTypes.string,
  audio_preview: React.PropTypes.string,
  form_type: React.PropTypes.string
};

PictureForm.defaultProps = {
  picture: {
    id: '',
    description: '',
    image: '',
    picture_interests_attributes: [],
    audio: ''
  },
  interests_list: [],
  picture_preview: '',
  audio_preview: '',
  form_type: 'create'
};
