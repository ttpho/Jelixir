defmodule Mix.Tasks.Jelixir do
  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    list_args = System.argv()

    if length(list_args) < 3 do
      nothing()
    else
      jelixir = Enum.at(list_args, 0) |> String.to_atom()
      re_work(jelixir, list_args |> tl)
    end
  end

  def re_work(:jelixir, list_args) do
    task = Enum.at(list_args, 0) |> String.trim() |> String.to_atom()
    input_task = Enum.at(list_args, 1) |> String.trim()
    work(task, input_task)
  end

  def re_work(_jelixir, _list_args), do: nothing()

  def work(:json, input_task), do: :json |> JelixirLib.conver(input_task)

  def work(:phx, input_task), do: :phx |> JelixirLib.conver(input_task)

  def work(:schema, input_task), do: :schema |> JelixirLib.conver(input_task)

  def work(_task, _input_task) do
    nothing()
  end

  def nothing(_message \\ "") do
    Mix.shell().info(~s(
Nothing to do! 🏝. Try
  For example:\n
    mix jelixir json book.json\n
    mix jelixir phx book.json))
  end
end
