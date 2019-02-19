class HeatmapTestingComponent extends React.Component {

  static get heatmapConfig() {
    return {
      container: $('#canvasRender')[0],
      radius: 25
    };
  }

  constructor(props){
    super(props);

    this.state = {
      number: props.number,
      heatmapData: props.heatmap_data,
      scale: props.scale,
      testing: props.testing
    };

    //Binds
    this.loadQuestion = this.loadQuestion.bind(this);
    this.drawCanvas = this.drawCanvas.bind(this);
  }

  loadQuestion(number) {
    $.ajax(this.props.heatmap_url, {
      dataType: 'json',
      data: {
        number: number
      },
      error: function () {
        window.alert('Something went wrong. Reload a page and ask your administrator!')
      },
      success: (data) => {
        let new_state = {
          ...this.state,
          number: data.number,
          heatmapData: data.heatmap_data,
          testing: data.testing
        };
        this.setState(new_state);
      }
    });
  }

  componentDidUpdate() {
    this.clearCanvas();
    this.drawCanvas();
  }

  drawCanvas() {

    let context = $('#canvasRender')[0].getContext('2d');

    html2canvas($('#test_container').get(0)).then(canvas => {
      let img = new Image();
      img.src = canvas.toDataURL('image/png');
      img.height = this.props.screen_height;
      img.onload = () => {
        context
          .drawImage(img, 0, 0, this.props.screen_width * this.state.scale, this.props.screen_height * this.state.scale);

        let heatmapInstance = h337.create(HeatmapTestingComponent.heatmapConfig);
        heatmapInstance.setData({
          max: 10,
          min: 1,
          data: this.state.heatmapData
        });

        let imgHeat = new Image();
        imgHeat.src = heatmapInstance.getDataURL();
        imgHeat.height = this.props.screen_height * this.state.scale;
        imgHeat.onload = () => {
          context
            .drawImage(imgHeat, 0, 0, this.props.screen_width * this.state.scale, this.props.screen_height * this.state.scale);
        };
      };

    });
  }

  clearCanvas() {
    let canvas = $('#canvasRender')[0].getContext('2d');
    canvas.clearRect(0, 0, canvas.width, canvas.height);
  }

  componentDidMount() {
    this.drawCanvas();
  }

  render () {
    let width = this.props.screen_width;
    let height = this.props.screen_height;

    return (
      <div>
        <div id="heatmaped_testing">
          <div style={{opacity: '0'}}>
            {this.renderTestingComponent(width, height)}
          </div>
        </div>
        <div className="carousel slide"
             style={{height: (height * this.state.scale) + 'px', width: (width * this.state.scale) + 'px'}}
        >
          <div className="carousel-inner" role="listbox">
            {this.renderCanvas(width, height)}
          </div>
          {this.renderButton('left', 'Previous', this.state.number - 1)}
          {this.renderButton('right', 'Next', this.state.number + 1)}
        </div>
      </div>
    );
  }

  renderCanvas(width, height) {
    return(
      <div className="item active">
        <canvas id='canvasRender'
                height={height * this.state.scale}
                width={width * this.state.scale}
        ></canvas>
      </div>
    );
  }

  renderTestingComponent(width, height) {
    return(
      <div className="positioning"
           id="test_container"
      >
        <div style={{width: width + 'px', height: height + 'px'}}>
          <div className="container">
            <TestingComponent { ...this.state.testing } key={this.state.number}/>
          </div>
        </div>
      </div>
    );
  }

  renderButton(direction, text, next, hidden = false) {
    if(hidden || next <= 0 || next > this.props.question_count) {
      return;
    }
    let wrapperClass = [direction, 'carousel-control'].join(' ');
    let glyphClass = ['glyphicon', 'glyphicon-chevron-' + direction].join(' ');

    return(
      <a className={wrapperClass}
         onClick={() => { this.loadQuestion(next) }}
         role="button"
      >
            <span className={glyphClass}
                  aria-hidden="true"
            ></span>
        <span className="sr-only">{text}</span>
      </a>
    );
  }
}

