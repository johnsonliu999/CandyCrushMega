alias CandyCrushMega.{Game}

# remove match test
_ = """
[
  - * / /
  / / + +
  / * / +
  / * / +
]

"""
b = %{
  0 => "-", 1 => "*", 2 => "/", 3 => "/",
  4 => "/", 5 => "/", 6 => "+", 7 => "+",
  8 => "/", 9 => "*", 10 => "/", 11 => "+",
  12 => "/",13 => "*", 14 => "/", 15 => "+",
}

{b_n,_} = b |> Game.remove_match

size = 4

print = fn board ->
  for i <- 0..size-1 do
    for j <- 0..size-1 do
      board |> Map.get(i*size+j)
    end
  end
end

p_b = print.(b)
p_b_n = print.(b_n)

p_b_n_n = print.(b_n |> Game.drop_down)

IO.inspect p_b, label: "Before"
IO.inspect p_b_n, label: "After"

IO.inspect p_b_n_n, label: "After_drop"

IO.inspect print.(b_n |> Game.drop_down |> Game.fill_board), label: "After Fill"
