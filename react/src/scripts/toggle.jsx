var Toggle = React.createClass({
  handleChecked: function(event){
    this.setState({checked: event.target.checked});
    this.props.onChange(event.target.checked);
  },
  getInitialState: function(){
    return {checked: this.props.defaultChecked}
  },
  propTypes: {
    affirmativeText: React.PropTypes.string,
    negativeText: React.PropTypes.string,
    onChange: React.PropTypes.func,
    defaultChecked: React.PropTypes.bool
  },
  getDefaultProps: function(){
    return {
      affirmativeText: "yes",
      negativeText: "no",
      onChange: function(value) {
        console.log(value);
      },
      defaultChecked: false
    };
  },
  render: function() {
    return (
      <div className="toggle">
        <label>
          <input type="checkbox" checked={!!this.state.checked} onChange={this.handleChecked} />
          <div className="bug-fix">
            <div className="text">
              <div className="affirmative">{this.props.affirmativeText}</div>
              <div className="negative">{this.props.negativeText}</div>
            </div>
            <svg className="handle" height="34" viewBox="0 0 35 34">
              <g>
                <rect x="13" y="13" fill="#777777" width="1" height="1"/>
                <rect x="16" y="13" fill="#777777" width="1" height="1"/>
                <rect x="19" y="13" fill="#777777" width="1" height="1"/>
                <rect x="13" y="16" fill="#777777" width="1" height="1"/>
                <rect x="16" y="16" fill="#777777" width="1" height="1"/>
                <rect x="19" y="16" fill="#777777" width="1" height="1"/>
                <rect x="13" y="19" fill="#777777" width="1" height="1"/>
                <rect x="16" y="19" fill="#777777" width="1" height="1"/>
                <rect x="19" y="19" fill="#777777" width="1" height="1"/>
              </g>
            </svg>
          </div>
        </label>
      </div>
    );
  }
});
