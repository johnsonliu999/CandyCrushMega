defmodule CandyCrushMega.UserIdGenerator do
  use Agent

  def start_link, do: Agent.start_link(fn -> 0 end, name: __MODULE__)

  def gen_id, do: Agent.get_and_update(__MODULE__, fn cur -> {cur, cur+1} end)

end
