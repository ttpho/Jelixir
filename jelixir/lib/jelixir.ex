defmodule JelixirLib do
  @default_folder_out "jelixir"
  @default_folder_template "lib/template"
  # Regex Pattern from GitHub User ID: @quangvo90
  @regex_pattern_module_name ~r/(defmodule)\s+([0-9a-z_-]+)\s+do/im
  @regex_pattern_schema_name ~r/(schema)\s+"([0-9a-z_-]+)"\s+do/im
  @regex_pattern_field ~r/(field)\s{0,}\(?\s{0,}:([0-9a-z_-]+),\s{0,}:([0-9a-z_-]+)\)?/im

  def conver(task, file_name_string) when task in [:json, :phx] do
    with {:read_file_result, {:ok, json_string}} <-
           {:read_file_result, read_file(file_name_string)},
         {:name_result, name} <- {:name_result, String.split(file_name_string, ".") |> hd},
         {:node_status, {:ok, node_result}} <-
           {:node_status, Poison.Parser.parse!(json_string) |> travel()} do
      if !File.exists?(@default_folder_out) do
        File.mkdir(@default_folder_out)
      end

      create_file(task, name, node_result)
    else
      {:read_file_result, _} -> IO.inspect("Can't read file with name: #{file_name_string}")
      {:name_result, _} -> IO.inspect("Can't parse file with name: #{file_name_string}")
      {:node_status, _} -> IO.inspect("Can't parse Json file")
    end
  end

  def conver(task, file_name_string) when task == :schema do
    with {:read_file_result, {:ok, file_content}} <-
           {:read_file_result, read_file(file_name_string, ".ex")} do
      if !File.exists?(@default_folder_out) do
        File.mkdir(@default_folder_out)
      end

      parse_schema_result =
        String.split(file_content, "\n")
        |> Enum.map(fn line ->
          line |> String.trim() |> read_line_schema()
        end)
        |> Enum.filter(fn item -> item != {"skip", nil} end)
        |> Enum.into(%{})

      module_name = parse_schema_result["module_name"]
      schema_name = parse_schema_result["schema_name"]

      node_result = Map.drop(parse_schema_result, ["module_name", "schema_name"])
      create_gen(module_name, schema_name, node_result)
    else
      {:read_file_result, _} -> IO.inspect("Can't read file with name: #{file_name_string}")
      {:name_result, _} -> IO.inspect("Can't parse file with name: #{file_name_string}")
    end
  end

  def conver(_task, _file_name_string) do
    {:error, "No thing to do"}
  end

  def read_line_schema(flat_line) do
    module_name_result = Regex.run(@regex_pattern_module_name, flat_line)
    schema_name_result = Regex.run(@regex_pattern_schema_name, flat_line)
    pattern_field_result = Regex.run(@regex_pattern_field, flat_line)

    matched_result =
      [module_name_result, schema_name_result, pattern_field_result]
      |> Enum.find(&(!is_nil(&1)))

    case matched_result do
      [_line, "defmodule", module_name] ->
        {"module_name", module_name}

      [_line, "schema", schema_name] ->
        {"schema_name", schema_name}

      [_line, "field", field_name, field_type] ->
        {field_name, ":#{field_type}"}

      _ ->
        {"skip", nil}
    end
  end

  def create_file(:json, name, node_result) do
    create_schema(name, node_result)
    create_migration(name, node_result)
  end

  def create_file(:phx, name, node_result) do
    create_gen(name, node_result)
  end

  def create_file(task, _name, _node_result) do
    IO.inspect("No thing to do with task #{task}")
  end

  def create_gen(name, node_result) do
    schema_name = String.downcase(name)
    module_name = String.capitalize(schema_name)
    create_gen(module_name, schema_name, node_result)
  end

  def create_gen(module_name, schema_name, node_result) do
    file_name = "#{schema_name}.jelixir"
    list = node_result |> Map.to_list()
    {last_item_key, _} = List.last(list)

    all_fileds_string =
      list
      |> Enum.reduce("", fn {k, v}, lines ->
        lines <>
          ~s(\t\t#{k}#{v}) <>
          if last_item_key == k do
            ""
          else
            " \\\n"
          end
      end)

    new_content =
      EEx.eval_file(file_path_template("gen.eex"),
        capitalize_module_name: module_name,
        schema_name: schema_name,
        all_fileds_string: all_fileds_string
      )

    save(file_name, new_content)
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
      EEx.eval_file(file_path_template("schema.eex"),
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
      EEx.eval_file(file_path_template("migration.eex"),
        capitalize_module_name: capitalize_module_name,
        schema_name: schema_name,
        all_fileds_string: all_fileds_string
      )

    save(file_name, new_content)
  end

  defp file_path_template(name), do: "#{@default_folder_template}/#{name}"

  def save(name, content) do
    file_path = "#{@default_folder_out}/#{name}"
    {:ok, file} = File.open(file_path, [:write])
    IO.binwrite(file, content)
    File.close(file)
  end

  def read_file(file_name_string, extension \\ ".json") do
    if file_name_string |> String.ends_with?(extension) do
      File.read(file_name_string)
    else
      {:error, "Don't support file with extension: #{extension}"}
    end
  end

  # test:
  # iex> Jelixir.filed_name("createdAt1") == "created_at1"
  # true
  def filed_name(name) do
    name
    |> String.graphemes()
    |> Enum.reduce(fn x, acc ->
      acc <>
        if x == String.upcase(x) && x != String.downcase(x) do
          "_#{String.downcase(x)}"
        else
          x
        end
    end)
  end
end
