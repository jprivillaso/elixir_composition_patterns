# Project Overview

This Phoenix application was built to demonstrate Ecto query composition patterns for a talk on Elixir design patterns.

## Quick Start

See **QUICK_START.md** for a 2-minute setup guide.

## What's Included

### 🆕 Query Debugging Helper

**`lib/elxir_composition/query_helper.ex`** - Pretty-print SQL queries with:
- ✅ Color-coded SQL keywords (yellow)
- ✅ Formatted with proper line breaks
- ✅ Parameter interpolation option
- ✅ Pipeable (returns the query)

Run the demo: `mix run demo_sql.exs`

### Application Files

#### Core Data Layer
- **`lib/elxir_composition/blog.ex`** - Main context demonstrating composition patterns
  - Base query functions
  - Private query composers
  - Public API functions
  - Advanced queries with joins and aggregations

#### Schemas
- **`lib/elxir_composition/blog/author.ex`** - Author schema
- **`lib/elxir_composition/blog/post.ex`** - Post schema
- **`lib/elxir_composition/blog/comment.ex`** - Comment schema

#### Web Interface
- **`lib/elxir_composition_web/live/blog_live.ex`** - LiveView with interactive demo
  - Dashboard with stats
  - Authors list with post counts
  - Posts list with creation form
  - Comments list with creation form

#### Database
- **`priv/repo/migrations/`** - Three migrations for the schema
- **`priv/repo/seeds.exs`** - Sample data with 3 authors, 6 posts, 8 comments

### Documentation Files

#### For Your Talk
- **`QUICK_START.md`** ⭐ Start here! 2-minute setup and demo guide
- **`TALK_SNIPPETS.md`** ⭐ Copy-paste code snippets for your presentation
- **`COMPOSITION_DEMO.md`** - Detailed explanation of all patterns
- **`README.md`** - Full project documentation

#### Development
- **`AGENTS.md`** - Phoenix/Elixir best practices and guidelines
- **`PROJECT_OVERVIEW.md`** - This file

## Architecture

```
┌─────────────────────────────────────────┐
│         Web Layer (LiveView)            │
│     lib/elxir_composition_web/          │
└────────────────┬────────────────────────┘
                 │
                 │ calls
                 ▼
┌─────────────────────────────────────────┐
│        Data Layer (Context)             │
│    lib/elxir_composition/blog.ex        │
│                                          │
│  Public Functions (API)                 │
│    ├─ list_authors()                    │
│    ├─ list_published_posts()            │
│    └─ count_authors()                   │
│                                          │
│  Private Composers                      │
│    ├─ base_posts_query()                │
│    ├─ published(query)                  │
│    ├─ by_author(query, id)              │
│    └─ ordered_by_published_date(query)  │
└────────────────┬────────────────────────┘
                 │
                 │ uses
                 ▼
┌─────────────────────────────────────────┐
│         Database Layer (Ecto)           │
│    lib/elxir_composition/blog/*.ex      │
│         priv/repo/migrations/           │
└─────────────────────────────────────────┘
```

## Composition Pattern Flow

```elixir
# 1. Start with base query
base_posts_query()
  #=> from(p in Post)

# 2. Apply composers (each transforms the query)
|> published()
  #=> from(p in Post, where: not is_nil(p.published_at))

|> ordered_by_published_date()
  #=> from(p in Post,
  #      where: not is_nil(p.published_at),
  #      order_by: [desc: p.published_at])

|> with_author()
  #=> from(p in Post,
  #      where: not is_nil(p.published_at),
  #      order_by: [desc: p.published_at],
  #      preload: [:author])

# 3. Execute
|> Repo.all()
  #=> [%Post{...}, %Post{...}, ...]
```

## Key Patterns Demonstrated

### 1. Base Queries
```elixir
defp base_posts_query, do: from(p in Post)
```

### 2. Query Transformers
```elixir
defp published(query) do
  from p in query, where: not is_nil(p.published_at)
end
```

### 3. Composition
```elixir
def list_published_posts do
  base_posts_query()
  |> published()
  |> ordered_by_published_date()
  |> with_author()
  |> Repo.all()
end
```

### 4. Joins & Aggregations
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

## Demo Flow for Your Talk

1. **Show the schema** (3 tables with relationships)
2. **Start with base queries** (foundation)
3. **Introduce composers** (single-purpose functions)
4. **Build up complexity** (pipe multiple composers)
5. **Show advanced patterns** (joins, aggregations)
6. **Live demo** (create records in the web interface)
7. **IEx examples** (try queries interactively)

## Testing the App

### Web Interface
```bash
mix phx.server
# Visit http://localhost:4000
```

### IEx Console
```bash
iex -S mix

# Try these:
alias ElxirComposition.Blog
Blog.list_published_posts()
Blog.list_authors_with_post_counts()
Blog.get_blog_stats()
```

## File Count Summary

- **Schemas**: 3 files (Author, Post, Comment)
- **Migrations**: 3 files
- **Context**: 1 file (Blog) - ~300 lines with extensive examples
- **LiveView**: 1 file - Full interactive interface
- **Documentation**: 6 files - Everything you need for your talk

## Benefits Highlighted

1. **Readable** - Function names describe intent
2. **Reusable** - Write once, compose everywhere
3. **Testable** - Test pieces in isolation
4. **Maintainable** - Changes propagate automatically
5. **Flexible** - Easy to add new combinations

## Need Help?

- Problems setting up? Check **QUICK_START.md**
- Need code snippets? Check **TALK_SNIPPETS.md**
- Want detailed explanations? Check **COMPOSITION_DEMO.md**
- Want full docs? Check **README.md**

Good luck with your talk! 🎤


