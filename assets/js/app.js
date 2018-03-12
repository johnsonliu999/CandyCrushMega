// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"
import ReactDom from "react-dom"
import React from 'react'
import Game from './components/game'

function init() {
  /*$('#gameBtn').click(() => {
    let game = $('#gameName').val();
    let channel = socket.channel(`game:${game}`, {})
    console.log(`game:${game}`);
    channel.join()
      .receive("ok", resp => console.log("Joined", resp))
      .receive("error", resp => console.log("Unable to join", resp))
  });*/
  if (document.getElementById('indexPage')) indexInit();
  if (document.getElementById('gamePage')) gameInit();


}

function indexInit() {
  $('#gameJoinBtn').click( () => {
    const gameName = $('#gameName').val();
    if (gameName) {
      window.location.href="/game/"+gameName;
    }
  })
}

function gameInit() {
  const game_root = document.getElementById('game');
  ReactDom.render(<Game socket={socket} />, game_root);
}

$(init)
