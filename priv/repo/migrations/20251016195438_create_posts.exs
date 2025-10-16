defmodule ElxirComposition.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string, null: false
      add :body, :text, null: false
      add :published_at, :utc_datetime
      add :author_id, references(:authors, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:posts, [:author_id])
    create index(:posts, [:published_at])
  end
end
