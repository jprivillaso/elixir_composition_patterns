# Code Snippets for Your Talk

Quick reference snippets to copy during your presentation.

## 1. Base Query Pattern

```elixir
# Private base queries - the foundation
defp base_authors_query, do: from(a in Author)
defp base_posts_query, do: from(p in Post)
defp base_comments_query, do: from(c in Comment)
```

## 2. Simple Query Composers

```elixir
# Each function does ONE thing
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

defp limit_results(query, limit) do
  from q in query, limit: ^limit
end
```

## 3. Basic Composition

```elixir
# Simple - just get all
def list_posts do
  base_posts_query()
  |> Repo.all()
end

# Add one filter
def list_published_posts do
  base_posts_query()
  |> published()
  |> Repo.all()
end
```

## 4. Multi-Step Composition

```elixir
# Compose multiple operations
def list_published_posts do
  base_posts_query()
  |> published()              # Filter
  |> ordered_by_published_date()  # Sort
  |> with_author()            # Preload
  |> Repo.all()               # Execute
end

# Add a limit
def list_latest_posts(limit) do
  base_posts_query()
  |> published()
  |> ordered_by_published_date()
  |> limit_results(limit)
  |> with_author()
  |> Repo.all()
end
```

## 5. Specific Use Cases - Same Composers

```elixir
# Author's posts
def list_posts_by_author(author_id) do
  base_posts_query()
  |> by_author(author_id)     # Different filter
  |> ordered_by_published_date()  # Same sort
  |> with_author()            # Same preload
  |> Repo.all()
end
```

## 6. Counting - Compose with Select

```elixir
# Total count
def count_posts do
  base_posts_query()
  |> select([p], count(p.id))
  |> Repo.one()
end

# Filtered count - reuse the composer!
def count_published_posts do
  base_posts_query()
  |> published()  # <- Same composer function
  |> select([p], count(p.id))
  |> Repo.one()
end
```

## 7. Joins with Group By

```elixir
# Authors with post counts
def list_authors_with_post_counts do
  from(a in Author,
    left_join: p in assoc(a, :posts),
    group_by: a.id,
    select: {a, count(p.id)},
    order_by: [desc: count(p.id)]
  )
  |> Repo.all()
end
```

## 8. Complex Filtering + Joins

```elixir
# Most active authors (published posts only)
def list_most_active_authors(limit) do
  from(a in Author,
    join: p in assoc(a, :posts),
    where: not is_nil(p.published_at),  # Filter in join
    group_by: a.id,
    select: {a, count(p.id)},
    order_by: [desc: count(p.id)],
    limit: ^limit
  )
  |> Repo.all()
end
```

## 9. Composing Joins

```elixir
# Private composer for joins
defp with_comments(query) do
  from p in query, join: c in assoc(p, :comments)
end

# Public function uses it
def list_posts_with_comments do
  base_posts_query()
  |> with_comments()      # Composer adds join
  |> with_author()        # Composer adds preload
  |> distinct(true)
  |> Repo.all()
end
```

## 10. Controller Pattern

```elixir
# In your controller/LiveView
def index(conn, _params) do
  posts = Blog.list_published_posts()
  render(conn, "index.html", posts: posts)
end

def latest(conn, %{"limit" => limit}) do
  posts = Blog.list_latest_posts(String.to_integer(limit))
  render(conn, "latest.html", posts: posts)
end
```

## Key Benefits to Emphasize

1. **Readability**
   ```elixir
   # What does this do? It's obvious!
   base_posts_query()
   |> published()
   |> ordered_by_published_date()
   |> limit_results(10)
   ```

2. **Reusability**
   ```elixir
   # Use `published()` everywhere
   list_published_posts()
   count_published_posts()
   list_latest_posts(5)
   ```

3. **Testability**
   ```elixir
   # Test each piece separately
   test "published filters correctly" do
     query = base_posts_query() |> published()
     # Assert on query structure
   end
   ```

4. **Flexibility**
   ```elixir
   # Different combinations for different needs
   base_posts_query() |> published() |> by_author(1)
   base_posts_query() |> by_author(1) |> limit_results(5)
   ```

## Comparison: Before vs After

### Before (Monolithic)
```elixir
def list_latest_author_posts(author_id, limit) do
  from(p in Post,
    where: p.author_id == ^author_id,
    where: not is_nil(p.published_at),
    order_by: [desc: p.published_at],
    limit: ^limit,
    preload: [:author]
  )
  |> Repo.all()
end
```

### After (Composed)
```elixir
def list_latest_author_posts(author_id, limit) do
  base_posts_query()
  |> by_author(author_id)
  |> published()
  |> ordered_by_published_date()
  |> limit_results(limit)
  |> with_author()
  |> Repo.all()
end
```

## IEx Demo Commands

```elixir
# Start IEx
iex -S mix

# Setup
alias ElxirComposition.{Blog, QueryHelper}
alias ElxirComposition.Blog.Post
import Ecto.Query

# Try these commands
Blog.count_authors()
Blog.list_published_posts()
Blog.list_latest_posts(3)
Blog.list_authors_with_post_counts()
Blog.get_blog_stats()
```

## 🎯 Pretty-Printing SQL (NEW!)

Use `QueryHelper` to show beautiful SQL output during your talk:

```elixir
# Pretty print any query
from(p in Post, where: not is_nil(p.published_at))
|> QueryHelper.sql()

# Show SQL with actual parameter values
from(p in Post, where: p.author_id == 1)
|> QueryHelper.sql(interpolate: true)

# Debug mode - SQL + parameters separately
from(p in Post, where: p.author_id == 1, limit: 5)
|> QueryHelper.debug()

# Show how composition builds up the query
IO.puts("\n=== Step 1: Base ===")
query = from(p in Post)
QueryHelper.sql(query)

IO.puts("\n=== Step 2: Add Filter ===")
query = from p in query, where: not is_nil(p.published_at)
QueryHelper.sql(query)

IO.puts("\n=== Step 3: Add Ordering ===")
query = from p in query, order_by: [desc: p.published_at]
QueryHelper.sql(query)
```

### Benefits for Your Talk

- ✅ Color-coded SQL keywords (yellow)
- ✅ Formatted with proper line breaks
- ✅ Can show parameters separately or interpolated
- ✅ Pipeable - returns the query so you can keep composing

See **QUERY_DEBUGGING.md** for full documentation!

