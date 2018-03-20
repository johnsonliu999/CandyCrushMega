import React, {Component} from "react"
import Board from "./board"

const SIZE = 5;

export default class Game extends Component {
  constructor(props) {
    super(props);
    this.state = {
      winner: null,
      goal: null,
      size: null,
      userId: null,
      player1: {id: -1, score: 0}, // player_id
      player2: {id: -1, score: 0}, // player_id
      spectators: [],
      messages: [],
      board: null, // key-value "12" => "*"
      channel: null,
      valid: false, // # it's player's turn
      index1: null,
      index2: null,
      matched: null
    }

    this._initGame = this._initGame.bind(this);
    this._updateGame = this._updateGame.bind(this);
    this.handleClick = this.handleClick.bind(this);
  }

  componentDidMount() {
    // TODO: join channel
    const url = window.location.href;
    const gameName = url.substr(url.lastIndexOf('/')+1);
    const topic = `game:${gameName}`;
    const channel = this.props.socket.channel(topic);
    this.setState({channel:channel});

    channel.on("player2_join", data => this._initGame(data.game));
    channel.on("spectator_join", data => this.setState({spectators: data.spectators}));
    channel.on("message", data => {this.setState({spectators: data.messages})});

    channel.on("turn:move", data => this.setState({
      board: data.board, index1: data.index1, index2: data.index2
    }));
    channel.on("turn:continue", data => {
      console.log("turn:continue", data);
      this._updateGame(data);
      this.setState({index1: null, index2: null});
    });
    channel.on("turn:finished", data => {
      console.log("turn:finished", data);
      console.log(this.state);
      this._updateGame(data);
      console.log(data.cur_player, this.state.userId);
      if (data.cur_player == this.state.userId) {
        console.log("Current Player");
        this.setState({valid:true});
      }
    });
    channel.on("turn:recover", data => {
      this.setState({board: data.board, index1: null, index2: null})
      if (data.cur_player == this.state.userId) this.setState({valid:true});
    });
    channel.on("game_over", data => this.setState({winner: data.winner, valid: false}));

    channel.join()
            .receive("ok", data => {
              console.log("Join succeed", data);
              this.setState({userId: data.user_id})
              if (data.role == "player2" || data.role == "spectator")
                this._initGame(data.game);
            })
            .receive("error", resp => console.log("Unable to join", resp));
  }

  componentWillUnmount() {
    // TODO: leave channel
  }

  // mainly used for update game state after matching
  _updateGame({board, player1, player2, matched}) {
    this.setState({
      board: board,
      player1: player1,
      player2: player2,
      matched: matched,
    });
  }

  _initGame(game) {
    this.setState({
      winner: game.winner,
      player1: game.player1,
      player2: game.player2,
      board: game.board,
      goal: game.goal,
      messages: game.messages,
      spectators: game.spectators,
      valid: this.state.userId == game.cur_player,
      size: game.size
    });
  }

  handleClick(index) {
    if (!this.state.valid) return;

    const {index1, index2} = this.state;
    if (!index1) this.setState({index1 : index})
    else {
      if (!this._isValid(this.state.size, index1, index)) {
        this.setState({index1: null, index2: null});
        return ;
      }

      this.setState({valid: false, index2 : index});
      this.state.channel.push("move", {index1 : index1, index2 : index});

    }
  }

  _isValid(size, index1, index2) {
    const i1 = Math.floor(index1 / size);
    const j1 = index1 % size;
    const i2 = Math.floor(index2 / size);
    const j2 = index2 % size;
    console.log(i1, i2, j1, j2);
    return Math.abs(i1-i2) == 1 && j1 == j2
          || Math.abs(j1-j2) == 1 && i1 == i2;

  }

  render() {
    return (
      <div>
        { this.state.board ?
          <div>
            {this.state.valid ?
              <p className="text-success">Your Turn</p> :
                <p className="text-danger">Opponent's Turn</p>}
           <Board
             board={this.state.board}
             size={this.state.size}
             handleClick={this.handleClick}
             index1={this.state.index1}
             index2={this.state.index2}
             matched={this.state.matched}
             />
         </div>
           : <div>Waiting for opponent...</div>}
          {
            // TODO: chat room
          }
      </div>
    );
  }
}
