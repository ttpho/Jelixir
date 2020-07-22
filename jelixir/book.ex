defmodule Book do
  use Ecto.Schema

  schema "book" do
		field(:code, :string)
		field(:created_at, :string)
		field(:edition, :string)
		field(:price, :integer)
		field(:publisher, :string)
		field(:title, :string)
		field(:updated_at, :string) 
  end
end