defmodule Jelixir do
  def conver(file_name_string) do
    with {:read_file_result, {:ok, json_string}} <-
           {:read_file_result, read_file(file_name_string)},
         {:name_result, name} <- {:name_result, String.split(file_name_string, ".") |> hd},
         {:node_status, {:ok, node_result}} <-
           {:node_status, Poison.Parser.parse!(json_string) |> travel()} do
      create_schema(name, node_result)
      create_migration(name, node_result)
    else
      {:read_file_result, _} -> IO.inspect("Can't read file with name: #{file_name_string}")
      {:name_result, _} -> IO.inspect("Can't parse file with name: #{file_name_string}")
      {:node_status, _} -> IO.inspect("Can't parse Json file")
    end
  end

  def conver_map(name, json_string) do
    with {:ok, node_result} <- Poison.Parser.parse!(json_string) |> travel() do
      create_schema(name, node_result)
      create_migration(name, node_result)
    end
  end

  def get_type(v) do
    cond do
      is_map(v) -> "{:array, :map}"
      is_integer(v) -> ":integer"
      is_binary(v) -> ":string"
      true -> ":string"
    end
  end

  def travel(node) do
    if is_map(node) do
      list_filed =
        node
        |> Enum.map(fn {k, v} -> {filed_name(k), get_type(v)} end)
        |> Enum.into(%{})

      {:ok, list_filed}
    else
      {:error, "todo implement"}
    end
  end

  def create_schema(name, node_result) do
    schema_name = String.downcase(name)
    capitalize_module_name = schema_name |> String.capitalize()

    file_name = "#{schema_name}.ex"
    list = node_result |> Map.to_list()
    {last_item_key, _} = List.last(list)

    all_fileds_string =
      list
      |> Enum.reduce("", fn {k, v}, lines ->
        lines <>
          ~s(\t\tfield\(:#{k}, #{v}\)) <>
          if last_item_key == k do
            ""
          else
            "\n"
          end
      end)

    new_content =
      EEx.eval_file("schema_template.eex",
        capitalize_module_name: capitalize_module_name,
        schema_name: schema_name,
        all_fileds_string: all_fileds_string
      )

    save(file_name, new_content)
  end

  def create_migration(name, node_result) do
    schema_name = String.downcase(name)
    file_name = "create_#{schema_name}.ex"
    capitalize_module_name = schema_name |> String.capitalize()

    list = node_result |> Map.to_list()
    {last_item_key, _} = List.last(list)

    all_fileds_string =
      list
      |> Enum.reduce("", fn {k, v}, lines ->
        lines <>
          ~s(\t\t\tadd\(:#{k}, #{v}\)) <>
          if last_item_key == k do
            ""
          else
            "\n"
          end
      end)

    new_content =
      EEx.eval_file("migration_template.eex",
        capitalize_module_name: capitalize_module_name,
        schema_name: schema_name,
        all_fileds_string: all_fileds_string
      )

    save(file_name, new_content)
  end

  def save(name, content) do
    {:ok, file} = File.open(name, [:write])
    IO.binwrite(file, content)
    File.close(file)
  end

  def read_file(file_name_string) do
    if file_name_string |> String.ends_with?(".json") do
      File.read(file_name_string)
    else
      {:error, "It is not json file extension"}
    end
  end

  # test:
  # iex> Jelixir.filed_name("createdAt") == "created_at"
  # true
  defp filed_name(name) do
    name
    |> String.graphemes()
    |> Enum.reduce("", fn x, acc ->
      acc <>
        if x == String.upcase(x) do
          "_#{String.downcase(x)}"
        else
          x
        end
    end)
  end
end
