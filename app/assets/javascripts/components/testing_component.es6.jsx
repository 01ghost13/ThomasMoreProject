class TestingComponent extends React.Component {
  static get answerValue() {
    return {
      thumbs_down: 1,
      question_mark: 2,
      thumbs_up: 3
    };
  }

  static get emotionScanInterval() { return 4000; }

  constructor(props) {
    super(props);
    this.state = {
      ...props.testing,
      rewrite: false,
      start_time: props.start_time,
      lock_buttons: false,
      gazeTrace: [],
      emotionStates: []
    };

    //Binds
    this.previousQuestion = this.previousQuestion.bind(this);
    this.nextQuestion = this.nextQuestion.bind(this);
    this.initWebGazer = this.initWebGazer.bind(this);
    this.gazeListener = this.gazeListener.bind(this);
    this.emotionListener = this.emotionListener.bind(this);

    //Callback initialisations

    if(this.props.mode !== 'heatmap') {

      if(this.props.webgazer || this.props.emotion_tracking) {
        $(document).ready(this.initWebGazer);
      }
    }

  }

  student_url() {
    return this.props.student_url.replace(':id', this.props.student_id);
  }

  switchIndicator(){
    let color = $('#webgazerFaceFeedbackBox').css('border-color');
    $('#gaze_indicator').css('background-color', color);
  }

  //Callbacks

  initWebGazer() {
    let gazeListener = this.gazeListener;
    let emotionListener = this.emotionListener;
    let emotionTracking = this.props.emotion_tracking;
    let gazeTracking = this.props.webgazer;
    let debug_mode = new URL(location.href).searchParams.get("debug");

    let checkIfReady =
      function checkIfReady() {
        if (window.webgazer !== undefined) {
          if(!webgazer.detectCompatibility()) {//Exit if wrong browser.
            alert('Your browser cant run Gazetracking');
            return;
          }
          let webTracker = webgazer.setRegression('weightedRidge')
                                   .setTracker('clmtrackr');

          if(gazeTracking) { webTracker.setGazeListener(gazeListener); }

          if(debug_mode) { webTracker.showPredictionPoints(true); }

          webTracker.begin();

          if(emotionTracking) {
            setTimeout(emotionListener, 1500); //Wait for load of video feed and grab emotion immediately
            setInterval(emotionListener, TestingComponent.emotionScanInterval);
          }

        } else {
          setTimeout(checkIfReady, 100);
        }
      };
    setTimeout(checkIfReady, 100);
  }

  gazeListener(data, clock) {
    this.switchIndicator();
    if(data === null || data === undefined) {
      return;
    }

    this.setState({
      gazeTrace: this.state.gazeTrace.concat({x: data.x, y: data.y})
    });
  }

  emotionListener() {
    let params = {};

    $.ajax({
      url: this.props.emotion_recogniser_url,
      contentType: 'application/octet-stream',
      processData: false,
      headers: {
        'Ocp-Apim-Subscription-Key': this.props.emotion_azure_key
      },
      type: "POST",
      data: this.makeScreenShotFromWebcam()
    })
    .done((data) => {
      this.setState({
        emotionStates: this.state.emotionStates.concat(_.get(data, ['0', 'faceAttributes', 'emotion'], {}))
      });
    })
    .fail(function(err) {
      console.log("Error: " + JSON.stringify(err));
    });
  }

  makeScreenShotFromWebcam() {
    let hidden_canvas = $('#picture_taker')[0],
        video = $('#webgazerVideoFeed')[0],
        width = video.videoWidth,
        height = video.videoHeight,
        // Context object for working with the canvas.
        context = hidden_canvas.getContext('2d');

    // Set the canvas to the same dimensions as the video.
    hidden_canvas.width = width;
    hidden_canvas.height = height;

    // Draw a copy of the current frame from the video on the canvas.
    context.drawImage(video, 0, 0, width, height);

    // Get an image dataURL from the canvas.
    return this.createBlob(hidden_canvas.toDataURL());
  }

  createBlob(dataURL) {
    let BASE64_MARKER = ';base64,';
    if (dataURL.indexOf(BASE64_MARKER) === -1) {
      let parts = dataURL.split(',');
      let contentType = parts[0].split(':')[1];
      let raw = decodeURIComponent(parts[1]);
      return new Blob([raw], { type: contentType });
    }
    let parts = dataURL.split(BASE64_MARKER);
    let contentType = parts[0].split(':')[1];
    let raw = window.atob(parts[1]);
    let rawLength = raw.length;

    let uInt8Array = new Uint8Array(rawLength);

    for (var i = 0; i < rawLength; ++i) {
      uInt8Array[i] = raw.charCodeAt(i);
    }

    return new Blob([uInt8Array], { type: contentType });
  }

  //Actions

  exitTesting(fallback_url = this.student_url()) {
    if(this.props.mode === 'heatmap') {
      return;
    }

    window.location.href = fallback_url
  }

  previousQuestion() {
    if(this.state.lock_buttons || this.props.mode === 'heatmap') {
      return;
    }

    let new_state = {
      ...this.state,
      current_question: { ...this.state.previous_question },
      previous_question: undefined,
      rewrite: true,
      gazeTrace: []
    };

    this.setState(new_state);
  }

  nextQuestion(answer) {
    if(this.state.lock_buttons || this.props.mode === 'heatmap') {
      return;
    }

    let data = {
      answer: TestingComponent.answerValue[answer],
      question: this.state.current_question,
      student_id: this.props.student_id,
      test_id: this.props.test_id,
      rewrite: this.state.rewrite,
      start_time: this.state.start_time
    };

    if(this.props.webgazer) {
      let cur_image = $('#cur_image');
      let cur_image_offset = cur_image.offset();
      data['gaze_trace_result_attributes'] = {
        gaze_points: this.state.gazeTrace,
        screen_width: screen.width,
        screen_height: screen.height,
        picture_bounds: [
          {
            x: cur_image_offset.left,
            y: cur_image.height() + cur_image_offset.top
          }, // down left
          {
            x: cur_image.width() + cur_image_offset.left,
            y: cur_image_offset.top
          }  // top right
        ]
      }
    }

    if(this.props.emotion_tracking) {
      data['emotion_state_result_attributes'] = {
        states: this.state.emotionStates
      }
    }

    $.ajax(
      'testing/update_picture', {
        type: 'POST',
        dataType: 'json',
        data: {
          ...data
        },
        beforeSend: () => {
          // lock buttons
          this.setState({lock_buttons: true});
          // [role='navigation_button']
        },
        error: (jqXHR, textStatus, errorThrown) => {
          console.log("AJAX Error: " + textStatus);
          window.alert('Some error occurred, please exit testing and try again later.');
          //Show decent message
        },
        success: (data, textStatus, jqXHR) => {
          // unlock buttons
          // redirect to result if it was last question
          if(data.result_url) {
            this.exitTesting(data.result_url);
            return;
          }

          let new_state = {
            ...this.state,
            rewrite: false,
            current_question: data.next_question,
            previous_question: this.state.current_question,
            start_time: data.start_time
          };

          this.setState(new_state);
        },
        complete: () => {
          this.setState({lock_buttons: false, gazeTrace: []})
        }
    });
  }

  //Renders

  render () {
    return (
      <div id="testing_component">
        {this.renderGazeIndicator()}
        {this.renderHiddenCanvas()}
        <div className="row">
          {this.renderInstructions()}

          <div className="col-sm-1">
            <img src={this.props.static_pics.btn_exit}
                 className="img-responsive"
                 id="btn_exit"
                 onClick={() => this.exitTesting()}
                 role="navigation_button"
            />
          </div>
        </div>

        <div className="row">
          <div className="col-sm-2">
            <div className="row">
              <img src={this.props.static_pics.btn_thumbs_up}
                   className='img-responsive'
                   id='btn_tu'
                   onClick={() => this.nextQuestion('thumbs_up')}
                   role="navigation_button"
              />
            </div>

            {this.renderBtnBack()}
          </div>

          {this.renderPicture()}

          <div className="col-sm-offset-1 col-sm-2">
            <div className="row">
              <img src={this.props.static_pics.btn_thumbs_down}
                   className='img-responsive'
                   id='btn_td'
                   onClick={() => this.nextQuestion('thumbs_down')}
                   role="navigation_button"
              />
            </div>

            <div className="row">
              <img src={this.props.static_pics.btn_question_mark}
                   className='img-responsive'
                   id='btn_qm'
                   onClick={() => this.nextQuestion('question_mark')}
                   role="navigation_button"
              />
            </div>
          </div>
        </div>
        <div className="row">
          {this.renderDescription()}
        </div>
        <div className="row">
          {this.renderProgressBar()}
        </div>
      </div>
    );
  }

  renderGazeIndicator() {
    return(
      <div className="indicator" id="gaze_indicator">
      </div>
    );
  }

  renderBtnBack() {
    if(this.state.current_question.number === 1 || this.state.rewrite)
      return '';

    return (
      <div className="row">
        <img src={this.props.static_pics.btn_back}
             className='img-responsive'
             id='btn_back'
             role="navigation_button"
             onClick={this.previousQuestion}
        />
      </div>
    );
  }

  renderInstructions() {
    return(
      <div className="col-sm-offset-1 col-sm-10">
        <div className="panel panel-default">
          <div className="panel-body">
            <p>Some instructions for user</p>
          </div>
        </div>
      </div>
    );
  }

  renderPicture() {
    return (
      <div className="col-sm-offset-1 col-sm-6">
        <img src={this.state.current_question.image_url}
             className='img-responsive'
             id='cur_image'
        />
      </div>
    );
  }

  renderDescription() {
    return (
      <div className="col-sm-offset-2 col-sm-8">
        <div className="panel panel-default">
          <div className="panel-body" id="description_id">
            <p>
              {this.state.current_question.description}
            </p>
          </div>
        </div>
      </div>
    );
  }

  renderProgressBar() {
    let progress_bar_value = (this.state.current_question.number - 1) / this.props.questions_count * 100.0;

    return (
      <div className="progress">
        <div id ="bar_id"
             className="progress-bar progress-bar-success progress-bar-striped active"
             role="progressbar"
             aria-valuenow={progress_bar_value}
             aria-valuemin="0"
             aria-valuemax="100"
             style={{width: progress_bar_value + '%'}}
        />
      </div>
    );
  }

  renderHiddenCanvas() {
    if(!this.props.emotion_tracking) {
      return;
    }
    return(
      <div style={{display: 'none'}}>
        <canvas id="picture_taker"
        ></canvas>
      </div>
    );
  }
}

TestingComponent.propTypes = {
  testing: React.PropTypes.shape({
    current_question: React.PropTypes.shape({
      image_url: React.PropTypes.string,
      description: React.PropTypes.string,
      number: React.PropTypes.number,
      id: React.PropTypes.number
    }),
    previous_question: React.PropTypes.shape({
      image_url: React.PropTypes.string,
      description: React.PropTypes.string,
      number: React.PropTypes.number,
      id: React.PropTypes.number
    })
  }),
  static_pics: React.PropTypes.shape({
    btn_back: React.PropTypes.string,
    btn_exit: React.PropTypes.string,
    btn_thumbs_down: React.PropTypes.string,
    btn_thumbs_up: React.PropTypes.string,
    btn_question_mark: React.PropTypes.string
  }),
  questions_count: React.PropTypes.number,
  test_id: React.PropTypes.number,
  student_id: React.PropTypes.number,
  webgazer: React.PropTypes.bool,
  emotion_tracking: React.PropTypes.bool,
  mode: React.PropTypes.string
};

TestingComponent.defaultProps = {
  testing: {
    current_question: {
      image_url: '',
      description: '',
      number: 0,
      id: ''
    },
    previous_question: {
      image_url: '',
      description: '',
      number: 0,
      id: ''
    }
  },
  static_pics: {
    btn_back: '#',
    btn_exit: '#',
    btn_thumbs_down: '#',
    btn_thumbs_up: '#',
    btn_question_mark: '#'
  },
  questions_count: 1,
  test_id: 0,
  student_id: 0,
  student_url: '/students/:id',
  webgazer: false,
  emotion_tracking: false,
  mode: ''
};
