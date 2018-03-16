defmodule CandyCrushMegaWeb.GameChannel do
  use CandyCrushMegaWeb, :channel
  alias CandyCrushMega.Game

  def join("game:" <> game_name, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :game_name, game_name)
      if :global.whereis_name({:game, game_name}) == :undefined do
        Game.create(game_name)
      end
      {role, game} = Game.join(Game.get(game_name), socket.assigns.user_id)
      user_id = socket.assigns.user_id
      case role do
        :player1 -> {:player1, %{user_id: user_id}}
        :player2 ->
          game = %{game | board: Game.new_board}
          broadcast_from socket, "player2_join", %{game: game}
          {:player2, %{user_id: user_id, game: game}}
        :spectator ->
          broadcast_from socket, "spectator_join", %{spectator: game.spectators}
          {:spectator, %{game: game}}
      end
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # return %{board, score}
  def handle_in("move", payload, socket) do

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

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
