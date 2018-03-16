alias CandyCrushMega.{Game}

defmodule CandyCrushMega.Test do

  @test1 %{
    0 => "-", 1 => "*", 2 => "/", 3 => "/",
    4 => "/", 5 => "/", 6 => "+", 7 => "+",
    8 => "/", 9 => "*", 10 => "/", 11 => "+",
    12 => "/",13 => "*", 14 => "/", 15 => "+",
  }

  @test2 %{
    0 => "-", 1 => "*", 2 => "/", 3 => "*",
    4 => "/", 5 => "/", 6 => "+", 7 => "-",
    8 => "*", 9 => "*", 10 => "/", 11 => "-",
    12 => "-",13 => "*", 14 => "/", 15 => "/",
  }

  @test_valid_move %{
    0 => '-', 1 => '+',
    2 => '*', 3 => '/',
  }

  @size 4

  def main do
    test_any_valid
  end

  def test_any_valid do
    @test1 |> Game.any_valid_move?
  end

  def test_remove do
    {b, matched} = @test1 |> Game.remove_match
    IO.inspect print(@test1), label: "Before"
    IO.inspect print(b), label: "After"
    IO.inspect print(b |> Game.drop_down), label: "After_drop"
    IO.inspect print(b |> Game.drop_down |> Game.fill_board), label: "After Fill"
  end

  def test_move(board) do
    {new_board, matched} = board |> Game.move(2, 6)
    IO.inspect print(new_board), label: "new_board"
    IO.inspect matched, label: "matched"
  end


  def print(board) do
    for i <- 0..@size-1 do
      for j <- 0..@size-1 do
        board |> Map.get(i*@size+j)
      end
    end
  end
end
