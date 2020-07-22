defmodule REPO_NAME.Migrations.CreateBookTable do
  use Ecto.Migration

  def change do
    create table("book") do
			add(:code, :string)
			add(:created_at, :string)
			add(:edition, :string)
			add(:price, :integer)
			add(:publisher, :string)
			add(:title, :string)
			add(:updated_at, :string)
      timestamps()
    end
  end
end