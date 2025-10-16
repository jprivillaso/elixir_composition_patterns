# Query Debugging Guide

This guide shows you how to pretty-print SQL queries for debugging and demonstration purposes.

## Quick Start

```elixir
iex -S mix

# Import the helper
alias ElxirComposition.{Blog, QueryHelper, Repo}
alias ElxirComposition.Blog.Post
import Ecto.Query
```

## Basic Usage

### Pretty Print SQL

```elixir
# Build a query and print its SQL
query = from p in Post, where: not is_nil(p.published_at)
QueryHelper.sql(query)

# Output:
# SELECT p0."id", p0."title", p0."body", p0."published_at", p0."author_id", ...
# FROM "posts" AS p0
# WHERE (NOT (p0."published_at" IS NULL))
```

### With Interpolated Parameters

```elixir
query = from p in Post, where: p.author_id == 1
QueryHelper.sql(query, interpolate: true)

# Parameters are shown in green instead of $1, $2, etc.
```

### Debug Mode (SQL + Parameters)

```elixir
query = from p in Post,
  where: p.author_id == 1 and not is_nil(p.published_at),
  order_by: [desc: p.published_at],
  limit: 5

QueryHelper.debug(query)

# Shows:
# SQL:
# SELECT ...
# FROM "posts" AS p0
# WHERE ...
#
# Parameters:
# [1]
```

### Explain Mode (SQL + Results)

```elixir
query = from p in Post, limit: 3
QueryHelper.explain(query)

# Shows SQL, then executes and shows results
```

## Using with Composed Queries

### Method 1: Pipe Before Repo.all()

```elixir
# In IEx
import Ecto.Query
alias ElxirComposition.Blog.Post

from(p in Post)
|> QueryHelper.sql()  # Prints SQL
|> where([p], not is_nil(p.published_at))
|> QueryHelper.sql()  # Prints updated SQL
|> order_by([p], desc: p.published_at)
|> QueryHelper.sql()  # Prints final SQL
|> Repo.all()         # Executes
```

### Method 2: Inspect Context Functions

To see SQL for Blog context functions, build the query manually:

```elixir
# Instead of calling Blog.list_published_posts()
# Manually compose it:

alias ElxirComposition.Blog.Post
import Ecto.Query

query = from(p in Post,
  where: not is_nil(p.published_at),
  order_by: [desc: p.published_at],
  preload: [:author]
)

QueryHelper.sql(query)
```

### Method 3: Temporarily Modify Context Functions

For your talk, you can temporarily add `QueryHelper.sql()` to any function:

```elixir
# In lib/elxir_composition/blog.ex
def list_published_posts do
  base_posts_query()
  |> published()
  |> ordered_by_published_date()
  |> with_author()
  |> QueryHelper.sql()  # <- Add this line
  |> Repo.all()
end

# Then in IEx:
Blog.list_published_posts()
# Prints the SQL, then returns results
```

## Examples for Your Talk

### Show Base Query

```elixir
alias ElxirComposition.Blog.Post
import Ecto.Query

from(p in Post) |> QueryHelper.sql()
```

### Show Composition Building Up

```elixir
alias ElxirComposition.Blog.Post
import Ecto.Query

# Step 1: Base
IO.puts("\n=== Base Query ===")
query = from(p in Post)
QueryHelper.sql(query)

# Step 2: Add filter
IO.puts("\n=== Add Published Filter ===")
query = from p in query, where: not is_nil(p.published_at)
QueryHelper.sql(query)

# Step 3: Add ordering
IO.puts("\n=== Add Ordering ===")
query = from p in query, order_by: [desc: p.published_at]
QueryHelper.sql(query)

# Step 4: Add limit
IO.puts("\n=== Add Limit ===")
query = from p in query, limit: 5
QueryHelper.sql(query)
```

### Show Joins and Aggregations

```elixir
alias ElxirComposition.Blog.{Author, Post}
import Ecto.Query

IO.puts("\n=== Authors with Post Counts ===")
query = from(a in Author,
  left_join: p in assoc(a, :posts),
  group_by: a.id,
  select: {a, count(p.id)},
  order_by: [desc: count(p.id)]
)

QueryHelper.sql(query)
```

### Compare Simple vs Complex

```elixir
alias ElxirComposition.Blog.Post
import Ecto.Query

IO.puts("\n=== Simple Query ===")
from(p in Post) |> QueryHelper.sql()

IO.puts("\n=== Complex Composed Query ===")
from(p in Post,
  where: not is_nil(p.published_at),
  where: p.author_id == 1,
  order_by: [desc: p.published_at],
  limit: 10,
  preload: [:author, :comments]
) |> QueryHelper.sql()
```

## API Reference

### `QueryHelper.sql(query, opts \\ [])`

Prints formatted SQL and returns the query (pipeable).

Options:
- `:interpolate` - When `true`, replaces `$1`, `$2` with actual values (default: `false`)

### `QueryHelper.debug(query)`

Prints SQL and parameters separately, returns the query.

### `QueryHelper.explain(query)`

Prints SQL, executes the query, and prints results. Returns results.

### `QueryHelper.to_sql_string(query, opts \\ [])`

Returns formatted SQL as a string without printing.

## Tips for Your Talk

1. **Use debug mode** to show how parameters are passed separately (prevents SQL injection)
2. **Use interpolate: true** for simpler output when demonstrating
3. **Pipe sql() between compositions** to show how the query builds up
4. **Keep terminal font size large** so the colored output is visible

## Color Legend

- **Yellow**: SQL keywords (SELECT, FROM, WHERE, etc.)
- **Green**: Parameter values (when using `interpolate: true`)
- **Cyan**: Section headers in debug mode

## Example Session for Demo

```elixir
# Start IEx
iex -S mix

# Setup
alias ElxirComposition.{Blog, QueryHelper, Repo}
alias ElxirComposition.Blog.{Author, Post, Comment}
import Ecto.Query

# Demo 1: Simple composition
IO.puts("\n=== DEMO 1: Simple Composition ===")
from(p in Post)
|> QueryHelper.sql()

# Demo 2: Add filter
IO.puts("\n=== DEMO 2: With Published Filter ===")
from(p in Post, where: not is_nil(p.published_at))
|> QueryHelper.sql()

# Demo 3: Full composition
IO.puts("\n=== DEMO 3: Full Composition ===")
from(p in Post,
  where: not is_nil(p.published_at),
  order_by: [desc: p.published_at],
  limit: 5,
  preload: [:author]
)
|> QueryHelper.sql()

# Demo 4: Joins
IO.puts("\n=== DEMO 4: Joins with Aggregation ===")
from(a in Author,
  left_join: p in assoc(a, :posts),
  group_by: a.id,
  select: {a, count(p.id)}
)
|> QueryHelper.sql()
```

