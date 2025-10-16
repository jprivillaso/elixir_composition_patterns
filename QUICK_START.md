# Quick Start Guide

Get up and running in 2 minutes!

## Setup (One Time)

```bash
cd /Users/juanrivillas/workspace/personal/elxir_composition
mix deps.get
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs
```

## Run the App

```bash
mix phx.server
```

Then visit: http://localhost:4000

## Demo the Composition Patterns

### 1. Show the Data Layer (`lib/elxir_composition/blog.ex`)

Open the file and scroll to:
- **Line ~262**: Base query functions
- **Line ~267**: Private query composers (the building blocks)
- **Line ~45**: Public functions using composition
- **Line ~163**: Advanced queries with joins

### 2. Demonstrate Live

In the web interface at http://localhost:4000:

1. **Dashboard tab**: Shows aggregated stats using composed queries
   - See `get_blog_stats()`, `list_most_active_authors()`, `list_posts_with_comment_counts()`

2. **Authors tab**: Create authors and see post counts
   - Demonstrates `list_authors_with_post_counts()` with left join + group by

3. **Posts tab**: Create posts and see the composition in action
   - Shows `list_published_posts()` using multiple composers

4. **Comments tab**: See nested relationships
   - Demonstrates `list_comments()` with nested preloads

### 3. Code Examples to Walk Through

#### Example 1: Simple Composition
```elixir
def list_published_posts do
  base_posts_query()        # Start with base
  |> published()            # Add filter
  |> ordered_by_published_date()  # Add sorting
  |> with_author()          # Add preload
  |> Repo.all()             # Execute
end
```

#### Example 2: Reusing Composers
```elixir
# Same composers, different combinations
def count_published_posts do
  base_posts_query()
  |> published()  # <- Same function as above!
  |> select([p], count(p.id))
  |> Repo.one()
end
```

#### Example 3: Complex with Params
```elixir
def list_latest_posts(limit) do
  base_posts_query()
  |> published()
  |> ordered_by_published_date()
  |> limit_results(limit)  # <- Dynamic parameter
  |> with_author()
  |> Repo.all()
end
```

### 4. Try in IEx

```bash
iex -S mix
```

```elixir
alias ElxirComposition.{Blog, QueryHelper}
alias ElxirComposition.Blog.Post
import Ecto.Query

# Simple queries
Blog.count_authors()
Blog.count_posts()
Blog.count_published_posts()

# Composed queries
Blog.list_published_posts()
Blog.list_latest_posts(3)

# Advanced queries
Blog.list_authors_with_post_counts()
Blog.list_posts_with_comment_counts()
Blog.list_most_active_authors(2)

# Get all stats
Blog.get_blog_stats()

# 🎯 NEW: Pretty-print SQL queries!
from(p in Post, where: not is_nil(p.published_at))
|> QueryHelper.sql()

# See QUERY_DEBUGGING.md for more examples
```

## Key Points for Your Talk

1. **Composition makes code readable**
   - Each function name describes what it does
   - The pipe operator shows the data flow

2. **Reusable building blocks**
   - Write `published()` once, use everywhere
   - DRY principle in action

3. **Easy to test**
   - Test each composer in isolation
   - Test composed functions with different combinations

4. **Flexible and maintainable**
   - Adding new combinations is trivial
   - Changing a composer updates all uses

5. **Database patterns**
   - Joins: `list_authors_with_post_counts()`
   - Group by: Same function above
   - Filtering: `published()`, `by_author()`
   - Aggregation: `count_*()` functions
   - Limits: `limit_results()`

## Additional Resources

- **COMPOSITION_DEMO.md**: Detailed pattern explanations
- **TALK_SNIPPETS.md**: Copy-paste code snippets
- **README.md**: Full project documentation

## Resetting Data

If you want fresh data:

```bash
mix ecto.reset
mix run priv/repo/seeds.exs
```

Good luck with your talk! 🚀

