import React, {Component} from "react"

export default class Board extends Component {

  render() {
    const {board, handleClick, index1, index2, matched} = this.props; // {"index": 'value'}
    const disp = [];
    const matched_set = new Set(matched);
    for (let i = 0; i < 25; i++) {
      let className = "col";
      if (matched_set.has(i)) className += " bg-success";
      if (i == index1 || i == index2) className += " bg-info";
      disp.push(
        <button key={i}
                className={className}
                onClick={() => handleClick(i)}>
        {board[i]}
        </button>)
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
