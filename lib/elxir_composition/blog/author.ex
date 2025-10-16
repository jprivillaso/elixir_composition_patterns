defmodule ElxirComposition.Blog.Author do
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :name, :string
    field :email, :string
    field :bio, :string

    has_many :posts, ElxirComposition.Blog.Post

    timestamps()
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:name, :email, :bio])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
