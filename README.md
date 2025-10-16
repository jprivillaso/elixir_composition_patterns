# Elixir Composition Demo

A Phoenix application demonstrating Ecto query composition patterns for a talk on Elixir design patterns.

## Overview

This application showcases how to build complex database queries through composition using Elixir's pipe operator and Ecto. The demo uses a simple blog system with Authors, Posts, and Comments.

## Setup

1. Install dependencies:
   ```bash
   mix deps.get
   ```

2. Create and migrate the database:
   ```bash
   mix ecto.create
   mix ecto.migrate
   ```

3. Seed with sample data:
   ```bash
   mix run priv/repo/seeds.exs
   ```

4. Start the Phoenix server:
   ```bash
   mix phx.server
   ```

5. Visit [`localhost:4000`](http://localhost:4000)

## What's Included

### Database Schema

- **Authors**: Blog authors with name, email, and bio
- **Posts**: Blog posts written by authors (with published_at timestamp)
- **Comments**: Comments on posts

### Composition Patterns

The `ElxirComposition.Blog` context (`lib/elxir_composition/blog.ex`) demonstrates:

1. **Base Query Functions** - Private functions that return base queries
   ```elixir
   defp base_posts_query, do: from(p in Post)
   ```

2. **Query Composers** - Reusable functions that transform queries
   ```elixir
   defp published(query), do: from p in query, where: not is_nil(p.published_at)
   defp by_author(query, id), do: from p in query, where: p.author_id == ^id
   ```

3. **Composed Public Functions** - Build complex queries through composition
   ```elixir
   def list_published_posts do
     base_posts_query()
     |> published()
     |> ordered_by_published_date()
     |> with_author()
     |> Repo.all()
   end
   ```

4. **Advanced Patterns** - Joins, aggregations, group by
   ```elixir
   def list_authors_with_post_counts do
     from(a in Author,
       left_join: p in assoc(a, :posts),
       group_by: a.id,
       select: {a, count(p.id)}
     )
     |> Repo.all()
   end
   ```

### Web Interface

The LiveView at `/` provides a dashboard showing:

- **Dashboard**: Blog statistics and most active authors
- **Authors**: List of authors with post counts, create new authors
- **Posts**: Published posts, create new posts
- **Comments**: All comments with context, create new comments

## For Your Talk

### Key Files to Show

1. **Data Layer**: `lib/elxir_composition/blog.ex`
   - Lines 262-264: Base query functions
   - Lines 267-290: Private query composers
   - Lines 45-92: Simple composed queries
   - Lines 163-220: Advanced queries with joins and aggregations

2. **Migrations**: `priv/repo/migrations/`
   - Shows the database schema

3. **Schemas**: `lib/elxir_composition/blog/`
   - Author, Post, Comment schemas with associations

### Demo Flow Suggestion

1. **Start with the basics**: Show base queries and simple composers
2. **Build up complexity**: Demonstrate how composers pipe together
3. **Show joins and aggregations**: Display complex queries that are still readable
4. **Live demo**: Create records through the web interface
5. **Show the power**: Compare a complex query built with composition vs. a monolithic query

### Example Queries to Demonstrate

```elixir
# Simple count
Blog.count_authors()

# Filtered and sorted
Blog.list_published_posts()

# Multi-step composition with limit
Blog.list_latest_posts(5)

# Complex aggregation
Blog.list_authors_with_post_counts()

# Multiple filters and joins
Blog.list_most_active_authors(3)
```

### 🎯 Pretty-Print SQL Queries

New! Use `QueryHelper` to show formatted SQL during your talk:

```elixir
alias ElxirComposition.{QueryHelper, Blog.Post}
import Ecto.Query

# Pretty print SQL with color-coding
from(p in Post, where: not is_nil(p.published_at))
|> QueryHelper.sql()

# Show step-by-step composition
query = from(p in Post)
QueryHelper.sql(query)  # Base query

query = from p in query, where: not is_nil(p.published_at)
QueryHelper.sql(query)  # With filter

query = from p in query, order_by: [desc: p.published_at]
QueryHelper.sql(query)  # With ordering
```

See **QUERY_DEBUGGING.md** for full documentation.

### Key Talking Points

1. **Single Responsibility**: Each function does one thing
2. **Composability**: Functions can be combined in any order
3. **Reusability**: Same composers used in multiple places
4. **Testability**: Each function can be tested in isolation
5. **Readability**: Intent is clear from function names

## Additional Documentation

See `COMPOSITION_DEMO.md` for detailed explanations of each pattern and more code examples.

## Resetting Data

To reset and reseed the database:

```bash
mix ecto.reset
mix run priv/repo/seeds.exs
```
