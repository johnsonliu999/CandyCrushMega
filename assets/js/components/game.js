import React, {Component} from "react"
import Board from "./board"

export default class Game extends Component {
  constructor(props) {
    super(props);
    this.state = {
      winner: null,
      player: {id: -1, score: 0}, // player_id
      opponent: {id: -1, score: 0}, // player_id
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

    channel.on("game:start", data => {
      const {players, board} = data;
      let opponent = {score: 0}
      if (players[0].id == this.state.player.id)
        opponent.id = players[1].id;
      else opponent.id = players[0].id;
      this.setState({
        opponent: opponent,
        board: board
      });
    });

    channel.join()
            .receive("ok", data => {
              console.log("Join Succeed", data);
              this.setState({player: {id: data["user_id"], score: 0})
            })
            .receive("error", resp => console.log("Unable to join", rsp));
  }

  componentWillUnmount() {
    // TODO: leave channel
  }

  render() {
    return (
      <div>
          <Status
            opponent={this.state.opponent}
            player={this.state.player}
            winner={this.state.winner}
             />
          <Board board={this.state.board}/>
      </div>
    );
  }
}
