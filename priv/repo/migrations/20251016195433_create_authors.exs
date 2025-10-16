defmodule ElxirComposition.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :bio, :text

      timestamps()
    end

    create unique_index(:authors, [:email])
  end
end
