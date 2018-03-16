defmodule CandyCrushMega.Game do
  use Agent, restart: :temporary

  @size 4
  @red "*"
  @blue "/"
  @green "+"
  @yellow "-"
  @tiles [@blue, @green, @yellow, @red]

  defstruct [
    winner: nil,
    cur_player: nil, # ids or token
    player1: nil, # %{id: :id(), score: :int()}
    player2: nil,
    spectators: [], # ids
    over: false,
    board: %{}, # %{index => '*'}
    messages: [] # list of {id, msg}
  ]

  ### game part
  @doc"""
  return {"ok", game_pid}
  """
  def create(game_name) do
    Agent.start_link(fn -> %__MODULE__{} end, name: ref(game_name))
  end

  def destroy(game_name) do
    Agent.stop(ref(game_name))
  end

  def get(game_name), do: Agent.get(ref(game_name), fn game -> game end)

  def update(game_name, game) do
    Agent.update(ref(game_name), fn -> game end)
  end

  defp ref(game_name), do: {:global, {:game, game_name}}

  ### player part
  # simply add user_id per the game
  # return {:stateus(), :game()}
  def join(game, user_id) do
    cond do
      !game.player1 -> {:player1, %__MODULE__{game | player1: %{id: user_id, score: 0}}}
      !game.player2 -> {:player2, %__MODULE__{game | player2: %{id: user_id, socre: 0}}}
      true -> {:spectator, %__MODULE__{game | spectators: [user_id | game.spectators]}}
    end
  end


  ### board part
  # must guarantee index, inde2 is adjacent
  # return : {new_board :map(), matched :list()}
  def move(board, index1, index2) do
    {new_board, matched} =
      board
      |> Map.put(index1, board[index2])
      |> Map.put(index2, board[index1])
      |> remove_match
    if matched != [] do
      new_board =
        new_board
        |> drop_down
        |> fill_board
    end
    {new_board, matched}
  end

  def any_valid_move?(board) do
    0..@size-2
    |> Enum.any?(fn i ->
      0..@size-2
      |> Enum.any?(fn j ->
        {_, matched1} = board |> move({i,j} |> cor2ind, {i,j+1} |> cor2ind)
        {_, matched2} = board |> move({i,j} |> cor2ind, {i+1,j} |> cor2ind)
        matched1 != [] || matched2 != []
      end)
    end)
  end


  def new_board do
    board =
      0..@size-1
      |> Enum.reduce(%{}, fn i, acc ->
        0..@size-1
        |> Enum.reduce(acc, fn j, acc ->
          Map.put(acc, cor2ind({i,j}), gen_tile(acc, {i,j}))
        end)
      end)
      if !any_valid_move?(board), do: new_board, else: board
  end

  # fill nil entry of the board with random tiles
  def fill_board(board) do
    0..@size-1
    |> Enum.reduce(board, fn i, acc ->
      0..@size-1
      |> Enum.reduce(acc, fn j, acc ->
        acc |> Map.put_new({i, j} |> cor2ind, @tiles |> Enum.random)
      end)
    end)
  end

  # drop down the non-nil value
  # return board :map()
  def drop_down(board) do
    0..@size-1
    |> Enum.reduce(board, fn j, acc ->
      {board, _} = @size-1..0
      |> Enum.reduce({acc, @size-1}, fn i, {acc, cur} ->
        val = acc |> Map.get({i,j} |> cor2ind)
        if val do
          acc = acc
          |> Map.delete({i,j} |> cor2ind)
          |> Map.put({cur, j} |> cor2ind, val)
          cur = cur - 1
        end
        {acc, cur}
      end)
      board
    end)
  end

  # remove the matched from board
  # return {board: map(), match: list()}
  # TODO: test
  def remove_match(old_board) do
    0..@size-1
    |> Enum.reduce({old_board, []}, fn i, acc ->
      0..@size-1
      |> Enum.reduce(acc, fn j, {board, match} ->
        if matched?(old_board, {i,j}) do
          board = Map.delete(board, {i,j} |> cor2ind)
          match = [{i,j} |> cor2ind | match]
        end
        {board, match}
      end)
    end)
  end

  # return whether current tile is in the match
  def matched?(board, {i,j}) do
    up = board |> Map.get(cor2ind({i-1,j}))
    up_up = board |> Map.get(cor2ind({i-2,j}))
    left = board |> Map.get(cor2ind({i,j-1}))
    left_left = board |> Map.get(cor2ind({i,j-2}))
    down = board |> Map.get(cor2ind({i+1,j}))
    down_down = board |> Map.get(cor2ind({i+2,j}))
    right = board |> Map.get(cor2ind({i,j+1}))
    right_right = board |> Map.get(cor2ind({i,j+2}))
    cur = board |> Map.get(cor2ind({i,j}))

    (up == up_up && up == cur) ||
    (up == cur && up == down) ||
    (down == cur && down == down_down) ||
    (left == left_left && left == cur) ||
    (left == cur && left == right) ||
    (right == cur && right == right_right)
  end

  # generate tiles for a new game and promise
  # there is not a match
  # param: board: map() - generated map
  # param: cor: tuple() - coordinate
  # return: new board with the coordinate filled with
  #         a new tile
  defp gen_tile(board, {i, j}) do
    cur_tile = Enum.random(@tiles)
    up = board |> Map.get(cor2ind({i-1,j}))
    up_up = board |> Map.get(cor2ind({i-2,j}))
    left = board |> Map.get(cor2ind({i,j-1}))
    left_left = board |> Map.get(cor2ind({i,j-2}))
    if (up == up_up && up == cur_tile) || (left == left_left && left == cur_tile) do
      gen_tile(board, {i, j})
    else
      cur_tile
    end
  end

  defp cor2ind({i,j}) do
    if i < 0 || i >= @size || j < 0 || j >= @size do
      -1
    else
      i * @size + j
    end
  end

  defp ind2cor(ind), do: {ind / @size, rem(ind, @size)}
end
