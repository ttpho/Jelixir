# elixir-json-conver

### Input 
- Json content

```json
{
  "code": "PPP12",
  "edition": "2st",
  "price": 23000,
  "publisher": "NXBGD",
  "title": "Toán học cao cấp"
}
```

- File name : `book`


### Ouput
Created schema file: `book.ex`

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