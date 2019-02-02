class TestingComponent extends React.Component {
  static get answerValue() {
    return {
      thumbs_down: 1,
      question_mark: 2,
      thumbs_up: 3
    };
  }

  constructor(props) {
    super(props);
    this.state = {
      ...props.testing,
      rewrite: false,
      start_time: props.start_time,
      lock_buttons: false,
      gazeTrace: []
    };

    //Binds
    this.previousQuestion = this.previousQuestion.bind(this);
    this.nextQuestion = this.nextQuestion.bind(this);
    this.initWebGazer = this.initWebGazer.bind(this);
    this.gazeListener = this.gazeListener.bind(this);

    //Callback initialisations

    if(this.props.webgazer && this.props.mode !== 'heatmap') {
      $(document).ready(this.initWebGazer);
    }

  }

  student_url() {
    return this.props.student_url.replace(':id', this.props.student_id);
  }

  //Callbacks

  initWebGazer() {
    let gazeListener = this.gazeListener;
    let checkIfReady =
      function checkIfReady() {
        if (window.webgazer !== undefined) {
          webgazer
            .setRegression('weightedRidge') /* currently must set regression and tracker */
            .setTracker('clmtrackr')
            .setGazeListener(gazeListener)
            .begin()
            .showPredictionPoints(true);
        } else {
          setTimeout(checkIfReady, 100);
        }
      };
    setTimeout(checkIfReady,100);
  }

  gazeListener(data, clock) {
    if(data === null || data === undefined) {
      return;
    }

    this.setState({
      gazeTrace: this.state.gazeTrace.concat({x: data.x, y: data.y})
    });
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

    $.ajax(
      'testing/update_picture', {
        type: 'POST',
        dataType: 'json',
        data: {
          answer: TestingComponent.answerValue[answer],
          question: this.state.current_question,
          student_id: this.props.student_id,
          test_id: this.props.test_id,
          rewrite: this.state.rewrite,
          start_time: this.state.start_time,
          gaze_trace_result_attributes: {
            gaze_points: this.state.gazeTrace,
            screen_width: screen.width,
            screen_height: screen.height
          }
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
  test_id: React.PropTypes.number
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
  student_url: '/students/:id'
};
