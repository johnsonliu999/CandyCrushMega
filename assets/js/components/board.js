import React, {Component} from "react"

export default class Board extends Component {

  render() {
    const {board, handleClick, index1, index2, matched, size} = this.props; // {"index": 'value'}
    const disp = [];
    const matched_set = new Set(matched);
    for (let i = 0; i < size * size; i++) {
      let className = "rounded col-" + (12 / size);
      if (matched_set.has(i)) className += " bg-success";
      if (i == index1 || i == index2) className += " bg-info";
      disp.push(
        <input  type="image"
                src={window.image_path + board[i] + ".svg"}
                key={i}
                className={className}
                onClick={() => handleClick(i)} />)
      if (i % size == size-1)
        disp.push(<div key={`b${i}`} className="w-100" />);
    }

    return (
      <div className="board row">
        {disp}
      </div>
    );
  }
}
