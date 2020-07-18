defmodule Book do
  use Ecto.Schema

  schema "book" do
    field :code, :string 
field :edition, :string 
field :price, :integer 
field :publisher, :string 
field :title, :string 

  end
end