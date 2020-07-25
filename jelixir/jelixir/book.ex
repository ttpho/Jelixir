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