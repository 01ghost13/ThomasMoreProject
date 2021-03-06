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
      emotionStates: [],
      questionsState: 'loading',
      preloadProgress: 0,
      preloadProgressMax: 0,
      questionsPreloadQueue: [],
      lastNumberPreloaded: this.lastEl(props.testing.questions).number,
      imgCache: [],
      currentAudio: ''
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

  componentDidMount() {
    this.preloadQuestions(this.props.testing.questions, true)
  }

  lastEl(array) {
    return array[array.length - 1]
  }

  findAudio(question) {
    for(let cachedTag of this.state.imgCache) {
      let id = 'question_' + question.id;

      if(id === cachedTag.id) {
        return cachedTag;
      }
    }
  }

  stopAudio() {
    let audioTag = this.state.currentAudio;

    if(audioTag === undefined || audioTag.tagName !== 'AUDIO') { return; }

    audioTag.pause();
    audioTag.currentTime = 0;

    this.setState({
      currentAudio: undefined
    });
  }

  playAudio(question) {
    const audioTag = this.findAudio(question);

    if(audioTag === undefined || audioTag.tagName !== 'AUDIO') { return; }

    audioTag.play();

    this.setState({
      currentAudio: audioTag
    });

  }
  
  client_url() {
    return this.props.client_url.replace(':id', this.props.user_id);
  }

  switchIndicator(){
    let color = $('#webgazerFaceFeedbackBox').css('border-color');
    $('#gaze_indicator').css('background-color', color);
  }

  isYoutube() {
    return !_.isEmpty(this.state.current_question.youtube_link)
  }

  isQuestionsLoading() {
    return this.state.questionsState === 'loading';
  }

  promiseImgLoad(question) {
    return new Promise(resolve => {
      const img = new Image();

      img.addEventListener('load', () => {
        // TODO: Fix later https://react-legacy.netlify.app/docs/state-and-lifecycle.html#state-updates-may-be-asynchronous
        this.setState({
          preloadProgress: this.state.preloadProgress += 1
        });
        resolve(img);
      });

      img.src = question.image_url;
      img.className = 'img-responsive';
      img.id = 'cur_image';
    });
  }

  promiseAudioLoad(question) {
    return new Promise(resolve => {
      const audio = new Audio();

      // Doesnt wait for full loading
      // https://stackoverflow.com/a/2763101/6147257
      audio.addEventListener('canplaythrough', () => {
        // TODO: Fix later https://react-legacy.netlify.app/docs/state-and-lifecycle.html#state-updates-may-be-asynchronous
        this.setState({
          preloadProgress: this.state.preloadProgress += 1
        });
        resolve(audio);
      });

      audio.src = question.audio_url;
      audio.id = 'question_' + question.id
    });
  }

  preloadQuestions(questions, first_load) {
    if(questions.length === 0) { return; }
    let preloadStarts = new Date();

    let promises = [];

    if(this.state.questionsState === 'background-loading') {
      this.setState({
        questionsPreloadQueue: this.state.questionsPreloadQueue.concat(questions),
      });
      return;
    }

    for (let i = 0; i < questions.length; ++i) {
      let question = questions[i];

      if(question.image_url !== undefined) {
        promises.push(this.promiseImgLoad(question));
      }

      if(question.audio_url !== undefined) {
        promises.push(this.promiseAudioLoad(question));
      }
    }

    this.setState({
      preloadProgress: 0,
      preloadProgressMax: promises.length
    });

    Promise
      .all(promises)
      .then(values => {

        if(this.state.questionsPreloadQueue.length !== 0) {
          this.preloadQuestions(this.state.questionsPreloadQueue);

          this.setState({
            questionsState: 'background-loading',
            questions: this.state.questions.concat(questions),
            questionsPreloadQueue: [],
            imgCache: this.state.imgCache.concat(values),
          });
        } else {

          this.setState({
            questionsState: 'finished',
            questions: this.state.questions.concat(questions),
            imgCache: this.state.imgCache.concat(values),
          });
        }
        // On first load activate audio after preloading all resources
        // Will not work if current page has audio and page is reloaded https://developers.google.com/web/updates/2017/09/autoplay-policy-changes
        if(first_load) {
          this.playAudio(this.state.current_question);
          let preloadFinishes = new Date();
          this.setState({
            loading_time: (preloadFinishes - preloadStarts) / 1000 // In sec
          });
        }
      });
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

  exitTesting(fallback_url = this.client_url()) {
    if(this.props.mode === 'heatmap') {
      return;
    }

    window.location.href = fallback_url
  }

  previousQuestion() {
    if(this.state.lock_buttons || this.props.mode === 'heatmap') {
      return;
    }
    this.stopAudio();

    let new_state = {
      current_question: { ...this.state.previous_question },
      previous_question: undefined,
      rewrite: true,
      gazeTrace: []
    };

    this.playAudio(new_state.current_question);
    this.setState(new_state);
  }

  loadQuestion(array, number) {
    for(let el of array) {
      if(el.number === number) { return el }
    }
    return undefined;
  }

  answerSent(data, textStatus, jqXHR) {
    // redirect to result if it was last question
    if(data.result_url) {
      this.exitTesting(data.result_url);
      return;
    }

    let questions = this.state.questions.concat(data.questions);

    // no increment bc number starts from 1
    // TODO make more convenient
    let number = this.state.current_question.number;

    let next_question = this.loadQuestion(this.state.questions, number + 1);
    let wait_for_preload = 'finished';

    if(next_question === undefined) {
      wait_for_preload = 'loading';
      next_question = this.loadQuestion(questions, number + 1);
    }

    this.preloadQuestions(data.questions);

    let new_state = {
      rewrite: false,
      current_question: next_question,
      previous_question: {...this.state.current_question},
      start_time: data.start_time,
      questions: questions,
      questionState: wait_for_preload,
      lastNumberPreloaded: this.lastEl(questions).number
    };

    // Removing timer after first load
    if(this.state.loading_time !== undefined) { new_state['loading_time'] = undefined }

    this.playAudio(new_state.current_question);
    this.setState(new_state);
  }

  nextQuestion(answer) {
    if(this.state.lock_buttons || this.props.mode === 'heatmap') {
      return;
    }

    this.stopAudio();

    let data = {
      answer: TestingComponent.answerValue[answer],
      question: this.state.current_question,
      client_id: this.props.client_id,
      test_id: this.props.test_id,
      rewrite: this.state.rewrite,
      start_time: this.state.start_time,
      last_available_question: this.state.lastNumberPreloaded,
    };

    // sending time diff
    if(this.state.loading_time !== undefined) { data['loading_time'] = this.state.loading_time }

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

    $.ajax(this.props.links.answer, {
      type: 'POST',
      dataType: 'json',
      data: data,
      beforeSend: () => { this.setState({lock_buttons: true}); },
      error: (jqXHR, textStatus, errorThrown) => {
        console.log("AJAX Error: " + textStatus);
        window.alert('Some error occurred, please exit testing and try again later.');
        //Show decent message
      },
      success: (data, textStatus, jqXHR) => {
        this.answerSent(data, textStatus, jqXHR);
      },
      complete: () => {
        this.setState({
          lock_buttons: false,
          gazeTrace: [],
          emotionStates: []
        })
      }
    });
  }

  //Renders

  render () {
    if(this.isQuestionsLoading()) {
      return this.renderLoadingScreen();
    }

    return (
      <div id="testing_component">
        {this.renderGazeIndicator()}
        {this.renderHiddenCanvas()}
        <div className="row">
          <div className="col-sm-3">

            <div className="row m-top-10">
              <div className="col-sm-10">
                {this.renderThumbsUp()}
              </div>
            </div>

            <div className="row m-top-10">
              <div className="col-sm-10">
                {this.renderBtnBack()}
              </div>
            </div>

          </div>

          <div className="col-sm-6">
            <div className="row">
              <div className="col-sm-12">
                {this.renderAttachment()}
              </div>
            </div>
          </div>

          <div className="col-sm-3">
            <div className="row">
              <div className="col-sm-offset-10 col-sm-3 exit-btn ">
                {this.renderExitBtn()}
              </div>
            </div>

            <div className="row m-top-10">
              <div className="col-sm-offset-2 col-sm-10">
                {this.renderThumbsDown()}
              </div>
            </div>

            <div className="row m-top-10">
              <div className="col-sm-offset-2 col-sm-10">
                {this.renderSkipBtn()}
              </div>
            </div>
          </div>
        </div>

        <div className="row description-row">
          {this.renderDescription()}
        </div>

        <div className="row">
          {this.renderProgressBar()}
        </div>
      </div>
    );
  }

  renderGazeIndicator() {
    if (!this.props.webgazer) { return; }

    return(
      <div className="indicator" id="gaze_indicator">
      </div>
    );
  }

  renderBtnBack() {
    if(this.state.current_question.number === 1 || this.state.rewrite)
      return '';

    return (
      <img src={this.props.static_pics.btn_back}
           className='img-responsive pull-right'
           id='btn_back'
           role="navigation_button"
           onClick={this.previousQuestion}
      />
    );
  }

  renderThumbsUp() {
    return(
      <img src={this.props.static_pics.btn_thumbs_up}
           className='img-responsive pull-right'
           id='btn_tu'
           onClick={() => this.nextQuestion('thumbs_up')}
           role="navigation_button"
      />
    );
  }

  renderThumbsDown() {
    return(
      <img src={this.props.static_pics.btn_thumbs_down}
           className='img-responsive'
           id='btn_td'
           onClick={() => this.nextQuestion('thumbs_down')}
           role="navigation_button"
      />
    );
  }

  renderSkipBtn() {
    return(
      <img src={this.props.static_pics.btn_question_mark}
           className='img-responsive'
           id='btn_qm'
           onClick={() => this.nextQuestion('question_mark')}
           role="navigation_button"
      />
    );
  }

  renderExitBtn() {
    return(
      <img src={this.props.static_pics.btn_exit}
           className="img-responsive"
           id="btn_exit"
           onClick={() => this.exitTesting()}
           role="navigation_button"
      />
    );
  }

  renderPicture() {
    return (
      <div className="crop-image">
        <img src={this.state.current_question.image_url}
             className='img-responsive'
             id='cur_image'
        />
      </div>
    );
  }

  renderEmbedYoutube() {
    // let youtube_link = 'http://www.youtube.com/embed/oHg5SJYRHA0?autoplay=1&loop=1';
    let youtube_link = this.state.current_question.youtube_link;

    return (
      <div style={{width: '100%', height: '100%'}}>
        <iframe is
                width="600"
                height="345"
                src={youtube_link}
                frameBorder="0"
                allowFullScreen=""
                allow='autoplay'
        />
      </div>
    );
  }

  renderAttachment() {
    if(this.isYoutube()) {
      return this.renderEmbedYoutube();
    } else {
      return this.renderPicture();
    }
  }

  renderDescription() {
    return (
      <div className="col-sm-offset-2 col-sm-8">
        <div className="panel panel-default">
          <div className="panel-body description-block"
               id="description_id"
          >
            <div className="description-text">
              {this.state.current_question.description}
            </div>
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

  renderLoadingScreen() {
    let progress_bar_value = this.state.preloadProgress / this.state.preloadProgressMax * 100.0;

    return(
      <div className='text-align-center loader-block'>
        <h2>{tf('testing_process.test_loading')}</h2>
        <span className='loader glyphicon glyphicon-refresh' aria-hidden="true"></span>
        <div className="progress">
          <div id ="bar_id"
               className="progress-bar progress-bar-primary progress-bar-striped active"
               role="progressbar"
               aria-valuenow={progress_bar_value}
               aria-valuemin="0"
               aria-valuemax="100"
               style={{width: progress_bar_value + '%'}}
          />
        </div>
      </div>
    );
  }
}

Question = {
  image_url: React.PropTypes.string,
  audio_url: React.PropTypes.string,
  youtube_link: React.PropTypes.string,
  description: React.PropTypes.string,
  number: React.PropTypes.number,
  id: React.PropTypes.number
};

TestingComponent.propTypes = {
  testing: React.PropTypes.shape({
    current_question: React.PropTypes.shape(Question),
    previous_question: React.PropTypes.shape(Question),
    questions: React.PropTypes.arrayOf(Question)
  }),
  static_pics: React.PropTypes.shape({
    btn_back: React.PropTypes.string,
    btn_exit: React.PropTypes.string,
    btn_thumbs_down: React.PropTypes.string,
    btn_thumbs_up: React.PropTypes.string,
    btn_question_mark: React.PropTypes.string
  }),
  links: React.PropTypes.shape({
    answer: React.PropTypes.string
  }),
  questions_count: React.PropTypes.number,
  test_id: React.PropTypes.number,
  client_id: React.PropTypes.number,
  user_id: React.PropTypes.number,
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
  client_id: 0,
  user_id: 0,
  client_url: '/clients/:id',
  webgazer: false,
  emotion_tracking: false,
  mode: '',
};
