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