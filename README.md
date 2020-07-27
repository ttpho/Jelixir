# Jelixir

![Jelixir](https://user-images.githubusercontent.com/3994863/88547225-a05e2000-d047-11ea-8252-609e3527d253.jpg)


| command | input | output |
| :---         | :---           |:---  |
| `mix jelixir json book.json`   | `book.json`     | - Created schema file: `jelixir/book.ex`</br>- Created migration file: `jelixir/create_book.ex`    |
| `mix jelixir phx book.json`     | `book.json`       | Created Phoenix tasks file: `jelixir/book.jelixir`      |
| `mix jelixir schema book.ex`    |    `book.ex`       | Created Phoenix tasks file: `jelixir/book.jelixir` |
|      |      |     |


1. Convert *JSON* content to elixir files:
- Schema file
- Migration file

2. Conver *JSON* content to phoenix script content, included `phx.gen.context`,`phx.gen.html` and `phx.gen.json` script:

3. Conver *Schema* content file to phoenix script content, included `phx.gen.context`,`phx.gen.html` and `phx.gen.json` script


### Input 
- JSON content: `book.json` for `mix jelixir json book.json`, `mix jelixir phx book.json` 

```json
{
  "code": "PPP12",
  "edition": "2st",
  "price": 23000,
  "publisher": "NXBGD",
  "title": "Toán học cao cấp",
  "createdAt": "2020/11/29",
  "updatedAt": "2020/11/29"
}
```

- Schema file: `book.ex` for  `mix jelixir schema book.ex`

```ex
defmodule Book do
  use Ecto.Schema

  schema "book" do
    field(:code, :string)
    field(:createdAt, :string)
    field(:edition, :string)
    field(:price, :integer)
    field(:publisher, :string)
    field(:title, :string)
    field(:updatedAt, :string) 
  end
end
```


### Ouput
- Created Phoenix tasks file: `jelixir/book.jelixir`

```ex
# Generates a context with functions around an Ecto schema.
# https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Context.html#content

mix phx.gen.context ModuleBook Book book \
    code:string \
    createdAt:string \
    edition:string \
    price:integer \
    publisher:string \
    title:string \
    updatedAt:string

# Generates controller, views, and context for an HTML resource. 
# https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Html.html#content

mix phx.gen.html ModuleBook Book book \
    code:string \
    createdAt:string \
    edition:string \
    price:integer \
    publisher:string \
    title:string \
    updatedAt:string

# Generates controller, views, and context for a JSON resource.
# https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Json.html#content

mix phx.gen.json ModuleBook Book book \
    code:string \
    createdAt:string \
    edition:string \
    price:integer \
    publisher:string \
    title:string \
    updatedAt:string

```

- Created schema file: `jelixir/book.ex`

```ex
defmodule Book do
  use Ecto.Schema

  schema "book" do
    field(:code, :string)
    field(:createdAt, :string)
    field(:edition, :string)
    field(:price, :integer)
    field(:publisher, :string)
    field(:title, :string)
    field(:updatedAt, :string) 
  end
end
```

- Created migration file: `jelixir/create_book.ex`

```ex
defmodule REPO_NAME.Migrations.CreateBookTable do
  use Ecto.Migration

  def change do
    create table("book") do
      add(:code, :string)
      add(:createdAt, :string)
      add(:edition, :string)
      add(:price, :integer)
      add(:publisher, :string)
      add(:title, :string)
      add(:updatedAt, :string)
      timestamps()
    end
  end
end
```
