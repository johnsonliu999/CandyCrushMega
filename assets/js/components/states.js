import React from 'react';

const States = ({valid, sp_mode, player, opponent, goal}) =>
(<div className={"row states"}>
<div className={"user-state col rounded " + (valid ? "border border-primary" : "")}>
  <p>
    <span>{sp_mode ? "Player1: " : "Current Player: "}</span>
    <span>{player.name + " (id: " + player.id + ')'}</span>
  </p>
  <div className={"progress"}>
    <div className={"progress-bar bg-success"}
      role="progressbar" style={{width: Math.floor(player.score * 100 / goal) + "%"}}>
      {player.score}
    </div>
  </div>
</div>

<div className={"user-state col rounded " + (!valid ? "border border-primary" : "")}>
  <p>
    <span>{sp_mode ? "Player2: " : "Opponent: "}</span>
    <span>{opponent.name + " (id: " +  opponent.id + ')'}</span>
  </p>
  <div className={"progress"}>
    <div className={"progress-bar bg-danger"}
      role="progressbar" style={{width: Math.floor(opponent.score * 100 / goal) + "%"}}>
      {opponent.score}
    </div>
  </div>
</div>
</div>);

export default States;
