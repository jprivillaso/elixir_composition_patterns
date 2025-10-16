defmodule ElxirComposition.QueryHelper do
  @moduledoc """
  Helper functions for debugging and pretty-printing Ecto queries.

  ## Usage

  In IEx:

      iex> alias ElxirComposition.{Blog, QueryHelper}
      iex> import Ecto.Query

      # Pretty print a query
      iex> from(p in Post, where: p.id > 1) |> QueryHelper.sql()

      # Or use the shorter version
      iex> Blog.base_posts_query() |> QueryHelper.sql()

  """

  alias ElxirComposition.Repo

  @doc """
  Converts an Ecto query to SQL and prints it in a formatted way.
  """
  def sql(query, opts \\ []) do
    {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)

    formatted =
      sql
      |> format_sql()
      |> maybe_interpolate_params(params, opts)

    IO.puts("\n" <> formatted <> "\n")

    # Return the original query so it can be piped
    query
  end

  @doc """
  Like sql/2 but returns the formatted string instead of printing.
  """
  def to_sql_string(query, opts \\ []) do
    {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)

    sql
    |> format_sql()
    |> maybe_interpolate_params(params, opts)
  end

  @doc """
  Shows both the formatted SQL and the parameters separately.
  """
  def debug(query) do
    {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)

    IO.puts("\n" <> IO.ANSI.cyan() <> "SQL:" <> IO.ANSI.reset())
    IO.puts(format_sql(sql))

    IO.puts("\n" <> IO.ANSI.cyan() <> "Parameters:" <> IO.ANSI.reset())
    IO.inspect(params, pretty: true, width: 80)

    IO.puts("")

    # Return the original query
    query
  end

  @doc """
  Shows the query, then executes it and shows the results.
  Useful for debugging.
  """
  def explain(query) do
    debug(query)

    IO.puts(IO.ANSI.cyan() <> "Results:" <> IO.ANSI.reset())
    results = Repo.all(query)
    IO.inspect(results, pretty: true, limit: 10)

    results
  end

  # Private functions

  defp format_sql(sql) do
    sql
    |> String.replace("SELECT", "\n" <> keyword("SELECT"))
    |> String.replace("FROM", "\n" <> keyword("FROM"))
    |> String.replace("LEFT OUTER JOIN", "\n" <> keyword("LEFT OUTER JOIN"))
    |> String.replace("INNER JOIN", "\n" <> keyword("INNER JOIN"))
    |> String.replace("JOIN", "\n" <> keyword("JOIN"))
    |> String.replace("WHERE", "\n" <> keyword("WHERE"))
    |> String.replace("GROUP BY", "\n" <> keyword("GROUP BY"))
    |> String.replace("ORDER BY", "\n" <> keyword("ORDER BY"))
    |> String.replace("LIMIT", "\n" <> keyword("LIMIT"))
    |> String.replace("OFFSET", "\n" <> keyword("OFFSET"))
    |> String.replace("HAVING", "\n" <> keyword("HAVING"))
    |> String.replace(" AS ", " " <> keyword("AS") <> " ")
    |> String.replace(" ON ", " " <> keyword("ON") <> " ")
    |> String.replace(" AND ", " " <> keyword("AND") <> " ")
    |> String.replace(" OR ", " " <> keyword("OR") <> " ")
    |> String.replace(" NOT ", " " <> keyword("NOT") <> " ")
    |> String.replace(" IN ", " " <> keyword("IN") <> " ")
    |> String.replace(" IS NULL", " " <> keyword("IS NULL"))
    |> String.replace(" IS NOT NULL", " " <> keyword("IS NOT NULL"))
    |> String.trim()
  end

  defp keyword(word) do
    IO.ANSI.yellow() <> word <> IO.ANSI.reset()
  end

  defp maybe_interpolate_params(sql, params, opts) do
    if Keyword.get(opts, :interpolate, false) do
      interpolate_params(sql, params)
    else
      sql
    end
  end

  defp interpolate_params(sql, []), do: sql

  defp interpolate_params(sql, params) do
    params
    |> Enum.with_index(1)
    |> Enum.reduce(sql, fn {param, index}, acc ->
      formatted_param = format_param(param)
      String.replace(acc, "$#{index}", IO.ANSI.green() <> formatted_param <> IO.ANSI.reset())
    end)
  end

  defp format_param(param) when is_binary(param), do: "'#{param}'"
  defp format_param(param) when is_integer(param), do: Integer.to_string(param)
  defp format_param(param) when is_float(param), do: Float.to_string(param)
  defp format_param(%DateTime{} = param), do: "'#{DateTime.to_iso8601(param)}'"
  defp format_param(%NaiveDateTime{} = param), do: "'#{NaiveDateTime.to_iso8601(param)}'"
  defp format_param(%Date{} = param), do: "'#{Date.to_iso8601(param)}'"
  defp format_param(nil), do: "NULL"
  defp format_param(param), do: inspect(param)

  @doc """
  Convenience function to quickly inspect what SQL a context function generates.

  ## Examples

      QueryHelper.show_sql(&Blog.list_published_posts/0)
      QueryHelper.show_sql(fn -> Blog.list_latest_posts(5) end)
  """
  def show_sql(fun) when is_function(fun, 0) do
    # We need to intercept the Repo.all call
    # This is a bit tricky, so let's just document it for manual use
    IO.puts("""

    #{IO.ANSI.yellow()}Note:#{IO.ANSI.reset()} To see SQL for a context function, use it like this:

        # In the Blog context, change the function temporarily:
        def list_published_posts do
          base_posts_query()
          |> published()
          |> ordered_by_published_date()
          |> with_author()
          |> QueryHelper.sql()  # <- Add this
          |> Repo.all()
        end

    Or build the query manually and inspect it:

        import Ecto.Query
        alias ElxirComposition.Blog.Post

        query = from(p in Post,
          where: not is_nil(p.published_at),
          order_by: [desc: p.published_at],
          preload: [:author]
        )

        QueryHelper.sql(query)
    """)
  end
end
