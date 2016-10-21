var Toggle = React.createClass({
  handleChecked: function(checked){
    this.setState({checked: checked});
    this.props.onChange(checked);
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
      onChange: function(value) {},
      defaultChecked: false
    };
  },
  componentDidMount: function() {
    $(ReactDOM.findDOMNode(this)).toggle({
      affirmativeText: this.props.affirmativeText,
      negativeText: this.props.negativeText,
      defaultChecked: this.state.checked,
      onChange: this.handleChecked
    })
  },
  render: function() {
    return (
      <input type="checkbox" />
    );
  }
});
