# elixir-json-conver

### Input 
- Json content: `book.json`

```json
{
  "code": "PPP12",
  "edition": "2st",
  "price": 23000,
  "publisher": "NXBGD",
  "title": "Toán học cao cấp"
}
```

- cmd : `iex> Jelixir.conver "book.json"`


### Ouput
- Created schema file: `book.ex`

```ex
defmodule Book do
  use Ecto.Schema

  schema "book" do
    field(:code, :string)
    field(:edition, :string)
    field(:price, :integer)
    field(:publisher, :string)
    field(:title, :string)
  end
end
```

- Created migration file: `create_book.ex`

```ex
defmodule REPO_NAME.Migrations.CreateBookTable do
  use Ecto.Migration

  def change do
    create table("book") do
      add(:code, :string)
      add(:edition, :string)
      add(:price, :integer)
      add(:publisher, :string)
      add(:title, :string)

      timestamps()
    end
  end
end
```
