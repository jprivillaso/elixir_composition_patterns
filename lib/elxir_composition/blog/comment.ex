defmodule ElxirComposition.Blog.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :body, :string
    field :author_name, :string

    belongs_to :post, ElxirComposition.Blog.Post

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :author_name])
    |> validate_required([:body, :author_name])
  end
end
