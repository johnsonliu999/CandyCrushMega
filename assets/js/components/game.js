import React, {Component} from "react"
import Board from "./board"

export default class Game extends Component {
  constructor(props) {
    super(props);
    this.state = {
      winner: null,
      players: [],
      spectors: [],
      messages: [],
      board: {}, // key-value "12" => "*"
      channel: null,
    }
  }

  componentDidMount() {
    // TODO: join channel
    const url = window.location.href;
    const gameName = url.substr(url.lastIndexOf('/')+1);
    const topic = `game:${gameName}`;
    const channel = this.props.socket.channel(topic);
    this.setState({channel:channel});

    channel.join()
            .receive("ok", resp => {
              console.log("Join Succeed", resp);
              this.setState({board:resp["game"]})
            })
            .receive("error", resp => console.log("Unable to join", rsp));

  }

  componentWillUnmount() {
    // TODO: leave channel
  }

  render() {
    return (
      <div>
          <Board board={this.state.board}/>
      </div>
    );
  }
}
