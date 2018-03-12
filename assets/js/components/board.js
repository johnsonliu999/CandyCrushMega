import React, {Component} from "react"

const Tile = ({value}) => (
  <button className={"tile "}>{value}</button>
);


export default class Board extends Component {

  render() {
    const {board} = this.props; // {"index": 'value'}
    const disp = [];
    for (let i = 0; i < 25; i++) {
      disp.push(<Tile key={i} className={"col"} value={`${board[i]}`}/>)
      if (i % 5 == 4)
        disp.push(<div key={`b${i}`} className="w-100" />);
    }

    return (
      <div className="board">
        <div className="row">
          {disp}
        </div>
      </div>
    );
  }
}
