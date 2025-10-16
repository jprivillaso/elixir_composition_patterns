#!/usr/bin/env elixir

# Demo script to show SQL query composition in action
# Run with: mix run demo_sql.exs

alias ElxirComposition.QueryHelper
alias ElxirComposition.Blog.{Author, Post}
import Ecto.Query

IO.puts("""

#{IO.ANSI.cyan()}╔════════════════════════════════════════════════════════╗
║        ECTO QUERY COMPOSITION DEMO                     ║
║        Showing how queries build up step by step       ║
╚════════════════════════════════════════════════════════╝#{IO.ANSI.reset()}

""")

# ============================================================================
# Demo 1: Simple Base Query
# ============================================================================

IO.puts("""
#{IO.ANSI.magenta()}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  DEMO 1: Base Query
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━#{IO.ANSI.reset()}
""")

IO.puts("Starting with the simplest possible query:\n")
from(p in Post) |> QueryHelper.sql()

Process.sleep(1000)

# ============================================================================
# Demo 2: Adding Filters
# ============================================================================

IO.puts("""
#{IO.ANSI.magenta()}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  DEMO 2: Adding a Filter (Published Posts Only)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━#{IO.ANSI.reset()}
""")

IO.puts("Adding WHERE clause to filter published posts:\n")
from(p in Post, where: not is_nil(p.published_at))
|> QueryHelper.sql()

Process.sleep(1000)

# ============================================================================
# Demo 3: Adding Ordering
# ============================================================================

IO.puts("""
#{IO.ANSI.magenta()}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  DEMO 3: Adding Order By
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━#{IO.ANSI.reset()}
""")

IO.puts("Adding ORDER BY to sort by published date:\n")
from(p in Post,
  where: not is_nil(p.published_at),
  order_by: [desc: p.published_at]
)
|> QueryHelper.sql()

Process.sleep(1000)

# ============================================================================
# Demo 4: Adding Limit
# ============================================================================

IO.puts("""
#{IO.ANSI.magenta()}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  DEMO 4: Adding Limit (Top 5 Posts)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━#{IO.ANSI.reset()}
""")

IO.puts("Adding LIMIT to get only the top 5:\n")
from(p in Post,
  where: not is_nil(p.published_at),
  order_by: [desc: p.published_at],
  limit: 5
)
|> QueryHelper.sql(interpolate: true)

Process.sleep(1000)

# ============================================================================
# Demo 5: Joins
# ============================================================================

IO.puts("""
#{IO.ANSI.magenta()}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  DEMO 5: Joins with Aggregation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━#{IO.ANSI.reset()}
""")

IO.puts("Authors with post counts (LEFT JOIN + GROUP BY):\n")
from(a in Author,
  left_join: p in assoc(a, :posts),
  group_by: a.id,
  select: {a, count(p.id)},
  order_by: [desc: count(p.id)]
)
|> QueryHelper.sql()

Process.sleep(1000)

# ============================================================================
# Demo 6: Complex Query
# ============================================================================

IO.puts("""
#{IO.ANSI.magenta()}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  DEMO 6: Complex Query (Multiple Conditions)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━#{IO.ANSI.reset()}
""")

IO.puts("Most active authors (published posts only, limited to top 3):\n")
from(a in Author,
  join: p in assoc(a, :posts),
  where: not is_nil(p.published_at),
  group_by: a.id,
  select: {a, count(p.id)},
  order_by: [desc: count(p.id)],
  limit: 3
)
|> QueryHelper.sql(interpolate: true)

Process.sleep(1000)

# ============================================================================
# Demo 7: Composition in Action
# ============================================================================

IO.puts("""
#{IO.ANSI.magenta()}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  DEMO 7: Step-by-Step Composition
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━#{IO.ANSI.reset()}
""")

IO.puts("""
This shows how you can build queries incrementally:

Step 1: Start with base
""")
query = from(p in Post)
QueryHelper.sql(query)

IO.puts("\nStep 2: Add filter (pipe it)")
query = from p in query, where: not is_nil(p.published_at)
QueryHelper.sql(query)

IO.puts("\nStep 3: Add ordering (pipe it again)")
query = from p in query, order_by: [desc: p.published_at]
QueryHelper.sql(query)

IO.puts("\nStep 4: Add limit (one more pipe)")
query = from p in query, limit: 3
QueryHelper.sql(query)

Process.sleep(1000)

# ============================================================================
# Summary
# ============================================================================

IO.puts("""

#{IO.ANSI.cyan()}╔════════════════════════════════════════════════════════╗
║                    KEY TAKEAWAYS                       ║
╚════════════════════════════════════════════════════════╝#{IO.ANSI.reset()}

#{IO.ANSI.green()}✓#{IO.ANSI.reset()} Queries build up step by step through composition
#{IO.ANSI.green()}✓#{IO.ANSI.reset()} Each step adds one piece of functionality
#{IO.ANSI.green()}✓#{IO.ANSI.reset()} The pipe operator makes it readable
#{IO.ANSI.green()}✓#{IO.ANSI.reset()} Complex queries are just simple pieces combined
#{IO.ANSI.green()}✓#{IO.ANSI.reset()} Reusable composers = DRY principle in action

#{IO.ANSI.yellow()}Try it yourself in IEx:#{IO.ANSI.reset()}

    iex -S mix
    alias ElxirComposition.{QueryHelper, Blog.Post}
    import Ecto.Query

    from(p in Post) |> QueryHelper.sql()

""")
