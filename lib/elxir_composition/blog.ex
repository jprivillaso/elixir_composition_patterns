defmodule ElxirComposition.Blog do
  @moduledoc """
  The Blog context - demonstrating query composition patterns.

  This module showcases how to build complex queries through composition
  using private base query functions that can be piped together.
  """

  import Ecto.Query, warn: false
  alias ElxirComposition.Repo
  alias ElxirComposition.Blog.{Author, Post, Comment}

  # ============================================================================
  # Authors
  # ============================================================================

  @doc """
  Returns the list of all authors.
  """
  def list_authors do
    base_authors_query()
    |> Repo.all()
  end

  @doc """
  Returns the count of authors.
  """
  def count_authors do
    base_authors_query()
    |> select([a], count(a.id))
    |> Repo.one()
  end

  @doc """
  Gets a single author with their posts preloaded.
  """
  def get_author!(id) do
    base_authors_query()
    |> preload(:posts)
    |> Repo.get!(id)
  end

  @doc """
  Creates an author.
  """
  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end

  # ============================================================================
  # Posts
  # ============================================================================

  @doc """
  Returns the list of all posts with authors preloaded.
  """
  def list_posts do
    base_posts_query()
    |> with_author()
    |> Repo.all()
  end

  @doc """
  Returns published posts only, ordered by publish date.
  """
  def list_published_posts do
    base_posts_query()
    |> published()
    |> ordered_by_published_date()
    |> with_author()
    |> Repo.all()
  end

  @doc """
  Returns the latest N published posts.
  """
  def list_latest_posts(limit) do
    base_posts_query()
    |> published()
    |> ordered_by_published_date()
    |> limit_results(limit)
    |> with_author()
    |> Repo.all()
  end

  @doc """
  Returns posts by a specific author.
  """
  def list_posts_by_author(author_id) do
    base_posts_query()
    |> by_author(author_id)
    |> ordered_by_published_date()
    |> with_author()
    |> Repo.all()
  end

  @doc """
  Counts total posts.
  """
  def count_posts do
    base_posts_query()
    |> select([p], count(p.id))
    |> Repo.one()
  end

  @doc """
  Counts published posts.
  """
  def count_published_posts do
    base_posts_query()
    |> published()
    |> select([p], count(p.id))
    |> Repo.one()
  end

  @doc """
  Gets a single post with author and comments preloaded.
  """
  def get_post!(id) do
    base_posts_query()
    |> preload([:author, :comments])
    |> Repo.get!(id)
  end

  @doc """
  Creates a post for an author.
  """
  def create_post(author_id, attrs \\ %{}) do
    %Post{author_id: author_id}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Publishes a post by setting published_at to now.
  """
  def publish_post(%Post{} = post) do
    post
    |> Post.changeset(%{published_at: DateTime.utc_now()})
    |> Repo.update()
  end

  # ============================================================================
  # Comments
  # ============================================================================

  @doc """
  Returns all comments with posts and authors preloaded.
  """
  def list_comments do
    base_comments_query()
    |> with_post_and_author()
    |> Repo.all()
  end

  @doc """
  Returns comments for a specific post.
  """
  def list_comments_for_post(post_id) do
    base_comments_query()
    |> by_post(post_id)
    |> ordered_by_date()
    |> Repo.all()
  end

  @doc """
  Counts total comments.
  """
  def count_comments do
    base_comments_query()
    |> select([c], count(c.id))
    |> Repo.one()
  end

  @doc """
  Creates a comment for a post.
  """
  def create_comment(post_id, attrs \\ %{}) do
    %Comment{post_id: post_id}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  # ============================================================================
  # Advanced Queries - Demonstrating Joins and Aggregations
  # ============================================================================

  @doc """
  Returns authors with their post counts (demonstrates join + group_by).
  Returns a list of tuples: {author, post_count}
  """
  def list_authors_with_post_counts do
    from(a in Author,
      left_join: p in assoc(a, :posts),
      group_by: a.id,
      select: {a, count(p.id)},
      order_by: [desc: count(p.id)]
    )
    |> Repo.all()
  end

  @doc """
  Returns posts with their comment counts (demonstrates join + group_by).
  Returns a list of tuples: {post, comment_count}
  """
  def list_posts_with_comment_counts do
    from(p in Post,
      left_join: c in assoc(p, :comments),
      preload: [:author],
      group_by: p.id,
      select: {p, count(c.id)},
      order_by: [desc: p.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Returns the most active authors (those with the most published posts).
  Demonstrates complex composition with joins, filters, and grouping.
  """
  def list_most_active_authors(limit) do
    from(a in Author,
      join: p in assoc(a, :posts),
      where: not is_nil(p.published_at),
      group_by: a.id,
      select: {a, count(p.id)},
      order_by: [desc: count(p.id)],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc """
  Returns all posts that have comments (demonstrates inner join).
  """
  def list_posts_with_comments do
    base_posts_query()
    |> with_comments()
    |> with_author()
    |> distinct(true)
    |> Repo.all()
  end

  @doc """
  Returns stats about the blog - demonstrates union-like aggregation.
  """
  def get_blog_stats do
    %{
      total_authors: count_authors(),
      total_posts: count_posts(),
      published_posts: count_published_posts(),
      total_comments: count_comments()
    }
  end

  # ============================================================================
  # Private Query Composition Functions
  # ============================================================================

  # Base queries
  defp base_authors_query, do: from(a in Author)
  defp base_posts_query, do: from(p in Post)
  defp base_comments_query, do: from(c in Comment)

  # Post query composers
  defp published(query) do
    from p in query, where: not is_nil(p.published_at)
  end

  defp by_author(query, author_id) do
    from p in query, where: p.author_id == ^author_id
  end

  defp ordered_by_published_date(query) do
    from p in query, order_by: [desc: p.published_at]
  end

  defp with_author(query) do
    from p in query, preload: [:author]
  end

  defp with_comments(query) do
    from p in query, join: c in assoc(p, :comments)
  end

  defp limit_results(query, limit) do
    from q in query, limit: ^limit
  end

  # Comment query composers
  defp by_post(query, post_id) do
    from c in query, where: c.post_id == ^post_id
  end

  defp ordered_by_date(query) do
    from c in query, order_by: [desc: c.inserted_at]
  end

  defp with_post_and_author(query) do
    from c in query, preload: [post: :author]
  end
end
