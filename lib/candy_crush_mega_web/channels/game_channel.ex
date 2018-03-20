defmodule CandyCrushMegaWeb.GameChannel do
  use CandyCrushMegaWeb, :channel
  alias CandyCrushMega.Game
  alias CandyCrushMega.GameSupervisor

  def join("game:" <> game_name, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :game_name, game_name)
      if :global.whereis_name({:game, game_name}) == :undefined do
        DynamicSupervisor.start_child(GameSupervisor, {Game, game_name})
      end
      {role, game} = Game.join(Game.get(game_name), socket.assigns.user_id)
      user_id = socket.assigns.user_id
      Game.update(game_name, game)
      case role do
        :player1 ->
          {:ok, %{role: "player1", user_id: user_id}, socket}
        :player2 ->
          send self(), {:player2_join, game}
          {:ok, %{role: "player2", user_id: user_id, game: game}, socket}
        :spectator ->
          send self(), {:spectator_join, game.spectators}
          {:ok, %{role: "spectator", user_id: user_id, game: game}, socket}
      end
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # return %{board, score}
  def handle_in("move", payload, socket) do
    index1 = payload["index1"]
    index2 = payload["index2"]
    game_name = socket.assigns.game_name
    user_id = socket.assigns.user_id
    game = Game.get(game_name)
    if game.cur_player == user_id && Game.valid_indices?(index1, index2) do
      cur_board = game.board |> Game.move(index1, index2)
      {next_board, cur_matched} = cur_board |> Game.match_once
      broadcast socket, "turn:move", %{board: cur_board, index1: index1, index2: index2}
      if cur_matched == [] do
        Process.send_after self(), {:recover, game.board, game.cur_player}, 1000
      else
        Process.sleep(1000)
        broadcast socket, "turn:continue",
        %{board: cur_board, player1: game.player1, player2: game.player2, matched: cur_matched}
        Process.send_after self(), {:continue, next_board, cur_matched}, 1000
      end
      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end

  def handle_info({:recover, board, cur_player}, socket) do
    broadcast socket, "turn:recover", %{board: board, cur_player: cur_player}
    {:noreply, socket}
  end

  def handle_info({:continue, board, last_matched}, socket) do
    game_name = socket.assigns.game_name
    game = Game.get(game_name)
    |> Map.put(:board, board)
    |> Game.update_score(last_matched)

    {next_board, cur_matched} = Game.match_once(board)
    if cur_matched != [] do
      Process.send_after(self(), {:continue, next_board, cur_matched}, 1000)
      broadcast socket, "turn:continue",
      %{board: game.board, player1: game.player1, player2: game.player2, matched: cur_matched}
    else
      game = game |> Game.swith_player
      broadcast socket, "turn:finished",
      %{board: game.board, player1: game.player1, player2: game.player2,
      cur_player: game.cur_player, matched: cur_matched}

      if game.winner do
        broadcast socket, "game_over", %{winner: game.winner}
      end

    end
    Game.update(game_name, game)
    {:noreply, socket}
  end

  def handle_info({:player2_join, game}, socket) do
    broadcast_from socket, "player2_join", %{game: game}
    {:noreply, socket}
  end

  def handle_info({:spectator_join, spectators}, socket) do
    broadcast_from socket, "spectator_join", %{spectators: spectators}
    {:noreply, socket}
  end

  # payload like %{user_id :int(), content: :string()}
  def handle_in("message", payload, socket) do
    game_name = socket.assigns.game_name
    game = Game.get(game_name)
    messages = [payload | game.messages]
    Game.update(game_name, %{game | messages: messages})
    broadcast socket, "message", %{messages: messages}
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def terminate({:shutdown, reason}, socket) do
    user_id = socket.assigns.user_id
    game_name = socket.assigns.game_name
    game = Game.get(game_name)
    if user_id == game.player1.id || user_id == game.player2.id do
      Game.destroy(game_name)
      broadcast socket, "game_over", %{reason: "Player left"}
      {:stop, :normal, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
