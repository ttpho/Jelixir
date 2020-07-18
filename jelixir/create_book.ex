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
