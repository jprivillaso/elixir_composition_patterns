# Elixir Query Composition Demo

This Phoenix application demonstrates query composition patterns in Ecto for a blog system.

## Schema Overview

The application has three related tables:

1. **Authors** - Blog authors with name, email, and bio
2. **Posts** - Blog posts written by authors
3. **Comments** - Comments on posts

## Composition Patterns Demonstrated

### Base Query Pattern

Each entity has a private base query function:

```elixir
defp base_authors_query, do: from(a in Author)
defp base_posts_query, do: from(p in Post)
defp base_comments_query, do: from(c in Comment)
```

### Simple Composition

Public functions compose base queries with additional operations:

```elixir
def list_authors do
  base_authors_query()
  |> Repo.all()
end

def count_authors do
  base_authors_query()
  |> select([a], count(a.id))
  |> Repo.one()
end
```

### Private Query Composers

Reusable private functions that transform queries:

```elixir
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

### Complex Composition Examples

#### Multiple Pipe Operations

```elixir
def list_published_posts do
  base_posts_query()
  |> published()
  |> ordered_by_published_date()
  |> with_author()
  |> Repo.all()
end

def list_latest_posts(limit) do
  base_posts_query()
  |> published()
  |> ordered_by_published_date()
  |> limit_results(limit)
  |> with_author()
  |> Repo.all()
end
```

#### Joins with Group By

```elixir
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

#### Complex Filters and Aggregations

```elixir
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
```

## Key Concepts for Your Talk

### 1. Single Responsibility
Each private function does one thing:
- `published()` - filters for published posts
- `by_author()` - filters by author
- `with_author()` - preloads author association

### 2. Composability
Functions can be combined in any order:
```elixir
base_posts_query()
|> published()
|> by_author(author_id)
|> ordered_by_published_date()
```

### 3. Reusability
The same composer functions are used in multiple public functions:
- `published()` is used in `list_published_posts()`, `list_latest_posts()`, etc.
- `with_author()` is used wherever we need author data

### 4. Testability
Each function can be tested in isolation.

### 5. Readability
The intent is clear from the function names:
```elixir
def list_latest_posts(5) do
  base_posts_query()      # Start with posts
  |> published()          # Only published ones
  |> ordered_by_published_date()  # Most recent first
  |> limit_results(5)     # Top 5
  |> with_author()        # Include author info
  |> Repo.all()           # Execute
end
```

## Running the Demo

1. Set up the database:
   ```bash
   mix ecto.create
   mix ecto.migrate
   mix run priv/repo/seeds.exs
   ```

2. Start the server:
   ```bash
   mix phx.server
   ```

3. Visit `http://localhost:4000`

## Example Queries to Demonstrate

Show the audience these patterns in `lib/elxir_composition/blog.ex`:

1. **Base queries** (lines ~262-264)
2. **Simple composers** (lines ~267-290)
3. **List functions using composition** (lines ~45-75)
4. **Aggregations with joins** (lines ~163-197)
5. **Complex multi-step compositions** (lines ~200-210)

