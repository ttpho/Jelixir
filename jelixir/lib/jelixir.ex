defmodule Jelixir do
  def conver(file_name_string) do
    with {:ok, json_string} <- read_file(file_name_string) do
      name = String.split(file_name_string, ".") |> hd

      with {:ok, node_result} <- Poison.Parser.parse!(json_string) |> travel(name) do
        create_schema(name, node_result)
        create_migration(name, node_result)
      end
    end
  end

  def get_type(v) do
    cond do
      is_map(v) -> "{:array, :map}"
      is_integer(v) -> ":integer"
      is_binary(v) -> ":string"
    end
  end

  def travel(node, _name) do
    if is_map(node) do
      list_filed =
        node
        |> Enum.map(fn {k, v} -> {k, get_type(v)} end)
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

    with {:ok, content} <- File.read("schema_template.txt") do
      all_fileds_string =
        node_result
        |> Map.to_list()
        |> Enum.reduce("", fn {k, v}, lines -> lines <> "field :#{k}, #{v} \n" end)

      new_content =
        content
        |> String.replace("capitalize_module_name", capitalize_module_name)
        |> String.replace("schema_name", schema_name)
        |> String.replace("ALL_FIEDS", all_fileds_string)

      save(file_name, new_content)
    end
  end

  def create_migration(name, node_result) do
    schema_name = String.downcase(name)
    file_name = "create_#{schema_name}.ex"
    capitalize_module_name = schema_name |> String.capitalize()

    with {:ok, content} <- File.read("migration_template.txt") do
      all_fileds_string =
        node_result
        |> Map.to_list()
        |> Enum.reduce("", fn {k, v}, lines -> lines <> "add :#{k}, #{v} \n" end)

      new_content =
        content
        |> String.replace("capitalize_module_name", capitalize_module_name)
        |> String.replace("schema_name", schema_name)
        |> String.replace("ALL_FIEDS", all_fileds_string)

      save(file_name, new_content)
    end
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
end
