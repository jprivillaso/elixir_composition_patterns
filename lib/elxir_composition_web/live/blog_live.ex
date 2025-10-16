defmodule ElxirCompositionWeb.BlogLive do
  use ElxirCompositionWeb, :live_view

  alias ElxirComposition.Blog

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page, :dashboard)
      |> load_dashboard_data()

    {:ok, socket}
  end

  @impl true
  def handle_event("show_" <> page, _params, socket) do
    socket =
      socket
      |> assign(:page, String.to_atom(page))
      |> load_page_data()

    {:noreply, socket}
  end

  def handle_event("create_author", %{"name" => name, "email" => email}, socket) do
    case Blog.create_author(%{name: name, email: email, bio: "Sample bio"}) do
      {:ok, _author} ->
        {:noreply, load_page_data(socket)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create author")}
    end
  end

  def handle_event("create_post", %{"author_id" => "", "title" => _title}, socket) do
    {:noreply, put_flash(socket, :error, "Please select an author")}
  end

  def handle_event("create_post", %{"author_id" => author_id, "title" => title}, socket) do
    case Blog.create_post(String.to_integer(author_id), %{title: title, body: "Sample post body"}) do
      {:ok, post} ->
        Blog.publish_post(post)
        {:noreply, load_page_data(socket)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create post")}
    end
  end

  def handle_event("create_comment", %{"post_id" => "", "author_name" => _name, "body" => _body}, socket) do
    {:noreply, put_flash(socket, :error, "Please select a post")}
  end

  def handle_event("create_comment", %{"post_id" => post_id, "author_name" => author_name, "body" => body}, socket) do
    case Blog.create_comment(String.to_integer(post_id), %{author_name: author_name, body: body}) do
      {:ok, _comment} ->
        {:noreply, load_page_data(socket)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create comment")}
    end
  end

  defp load_dashboard_data(socket) do
    stats = Blog.get_blog_stats()

    socket
    |> assign(:stats, stats)
    |> assign(:posts_with_counts, Blog.list_posts_with_comment_counts())
    |> assign(:active_authors, Blog.list_most_active_authors(5))
  end

  defp load_page_data(socket) do
    case socket.assigns.page do
      :dashboard -> load_dashboard_data(socket)
      :authors -> assign(socket, :authors, Blog.list_authors_with_post_counts())
      :posts -> assign(socket, :posts, Blog.list_published_posts())
      :comments -> assign(socket, :comments, Blog.list_comments())
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 overflow-x-hidden">
      <div class="container mx-auto px-4 py-8 max-w-7xl">
        <header class="mb-8">
          <h1 class="text-2xl md:text-4xl font-bold text-gray-800 mb-2">Blog Composition Demo</h1>
          <p class="text-gray-600">Demonstrating Ecto query composition patterns</p>
        </header>

        <nav class="mb-8 flex flex-wrap gap-2">
          <button
            phx-click="show_dashboard"
            class={[
              "px-4 md:px-6 py-2 rounded-lg font-medium transition-colors text-sm md:text-base",
              @page == :dashboard && "bg-indigo-600 text-white",
              @page != :dashboard && "bg-white text-gray-700 hover:bg-gray-50"
            ]}
          >
            Dashboard
          </button>
          <button
            phx-click="show_authors"
            class={[
              "px-4 md:px-6 py-2 rounded-lg font-medium transition-colors text-sm md:text-base",
              @page == :authors && "bg-indigo-600 text-white",
              @page != :authors && "bg-white text-gray-700 hover:bg-gray-50"
            ]}
          >
            Authors
          </button>
          <button
            phx-click="show_posts"
            class={[
              "px-4 md:px-6 py-2 rounded-lg font-medium transition-colors text-sm md:text-base",
              @page == :posts && "bg-indigo-600 text-white",
              @page != :posts && "bg-white text-gray-700 hover:bg-gray-50"
            ]}
          >
            Posts
          </button>
          <button
            phx-click="show_comments"
            class={[
              "px-4 md:px-6 py-2 rounded-lg font-medium transition-colors text-sm md:text-base",
              @page == :comments && "bg-indigo-600 text-white",
              @page != :comments && "bg-white text-gray-700 hover:bg-gray-50"
            ]}
          >
            Comments
          </button>
        </nav>

        <%= cond do %>
          <% @page == :dashboard -> %>
            <div class="space-y-6">
              <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div class="bg-white rounded-lg shadow p-6">
                  <div class="text-gray-500 text-sm font-medium">Total Authors</div>
                  <div class="text-3xl font-bold text-indigo-600">{@stats.total_authors}</div>
                </div>
                <div class="bg-white rounded-lg shadow p-6">
                  <div class="text-gray-500 text-sm font-medium">Total Posts</div>
                  <div class="text-3xl font-bold text-blue-600">{@stats.total_posts}</div>
                </div>
                <div class="bg-white rounded-lg shadow p-6">
                  <div class="text-gray-500 text-sm font-medium">Published Posts</div>
                  <div class="text-3xl font-bold text-green-600">{@stats.published_posts}</div>
                </div>
                <div class="bg-white rounded-lg shadow p-6">
                  <div class="text-gray-500 text-sm font-medium">Total Comments</div>
                  <div class="text-3xl font-bold text-purple-600">{@stats.total_comments}</div>
                </div>
              </div>

              <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-2xl font-bold text-gray-800 mb-4">Most Active Authors</h2>
                <div class="space-y-2">
                  <%= for {author, post_count} <- @active_authors do %>
                    <div class="flex justify-between items-center p-3 bg-gray-50 rounded">
                      <div>
                        <div class="font-medium text-gray-800">{author.name}</div>
                        <div class="text-sm text-gray-500">{author.email}</div>
                      </div>
                      <div class="text-indigo-600 font-bold">{post_count} posts</div>
                    </div>
                  <% end %>
                </div>
              </div>

              <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-2xl font-bold text-gray-800 mb-4">Recent Posts with Comment Counts</h2>
                <div class="space-y-3">
                  <%= for {post, comment_count} <- @posts_with_counts do %>
                    <div class="border-l-4 border-indigo-600 pl-4 py-2">
                      <div class="font-medium text-gray-800">{post.title}</div>
                      <div class="text-sm text-gray-500">
                        by {post.author.name} • {comment_count} comments
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>

          <% @page == :authors -> %>
            <div class="space-y-6">
              <div class="bg-white rounded-lg shadow p-4 md:p-6">
                <h2 class="text-xl md:text-2xl font-bold text-gray-800 mb-4">Create New Author</h2>
                <form phx-submit="create_author" class="flex flex-col md:flex-row gap-3" id="author-form">
                  <input
                    type="text"
                    name="name"
                    placeholder="Name"
                    class="flex-1 px-4 py-2 border border-gray-300 rounded-lg bg-white text-gray-900 placeholder-gray-400 focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
                    required
                  />
                  <input
                    type="email"
                    name="email"
                    placeholder="Email"
                    class="flex-1 px-4 py-2 border border-gray-300 rounded-lg bg-white text-gray-900 placeholder-gray-400 focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
                    required
                  />
                  <button
                    type="submit"
                    class="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors font-medium"
                  >
                    Create
                  </button>
                </form>
              </div>

              <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-2xl font-bold text-gray-800 mb-4">
                  Authors with Post Counts
                </h2>
                <div class="space-y-3">
                  <%= for {author, post_count} <- @authors do %>
                    <div class="flex justify-between items-center p-4 border border-gray-200 rounded-lg">
                      <div>
                        <div class="font-semibold text-gray-800">{author.name}</div>
                        <div class="text-sm text-gray-500">{author.email}</div>
                        <%= if author.bio do %>
                          <div class="text-sm text-gray-600 mt-1">{author.bio}</div>
                        <% end %>
                      </div>
                      <div class="text-right">
                        <div class="text-2xl font-bold text-indigo-600">{post_count}</div>
                        <div class="text-sm text-gray-500">posts</div>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>

          <% @page == :posts -> %>
            <div class="space-y-6">
              <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-2xl font-bold text-gray-800 mb-4">Create New Post</h2>
                <form phx-submit="create_post" class="flex gap-3" id="post-form">
                  <select
                    name="author_id"
                    class="px-4 py-2 border border-gray-300 rounded-lg bg-white text-gray-900 focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
                    required
                  >
                    <option value="">Select Author</option>
                    <%= for {author, _} <- Blog.list_authors_with_post_counts() do %>
                      <option value={author.id}>{author.name}</option>
                    <% end %>
                  </select>
                  <input
                    type="text"
                    name="title"
                    placeholder="Post Title"
                    class="flex-1 px-4 py-2 border border-gray-300 rounded-lg bg-white text-gray-900 placeholder-gray-400 focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
                    required
                  />
                  <button
                    type="submit"
                    class="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors font-medium"
                  >
                    Create
                  </button>
                </form>
              </div>

              <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-2xl font-bold text-gray-800 mb-4">Published Posts</h2>
                <div class="space-y-4">
                  <%= for post <- @posts do %>
                    <article class="border-b border-gray-200 pb-4 last:border-b-0">
                      <h3 class="text-xl font-semibold text-gray-800 mb-2">{post.title}</h3>
                      <div class="text-gray-600 mb-2">{post.body}</div>
                      <div class="flex gap-4 text-sm text-gray-500">
                        <span>By {post.author.name}</span>
                        <%= if post.published_at do %>
                          <span>
                            Published: {Calendar.strftime(post.published_at, "%B %d, %Y")}
                          </span>
                        <% end %>
                      </div>
                    </article>
                  <% end %>
                </div>
              </div>
            </div>

          <% @page == :comments -> %>
            <div class="space-y-6">
              <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-2xl font-bold text-gray-800 mb-4">Create New Comment</h2>
                <form phx-submit="create_comment" class="space-y-3" id="comment-form">
                  <div class="flex gap-3">
                    <select
                      name="post_id"
                      class="flex-1 px-4 py-2 border border-gray-300 rounded-lg bg-white text-gray-900 focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
                      required
                    >
                      <option value="">Select Post</option>
                      <%= for post <- Blog.list_published_posts() do %>
                        <option value={post.id}>{post.title}</option>
                      <% end %>
                    </select>
                    <input
                      type="text"
                      name="author_name"
                      placeholder="Your Name"
                      class="flex-1 px-4 py-2 border border-gray-300 rounded-lg bg-white text-gray-900 placeholder-gray-400 focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
                      required
                    />
                  </div>
                  <div class="flex gap-3">
                    <textarea
                      name="body"
                      placeholder="Comment text"
                      rows="3"
                      class="flex-1 px-4 py-2 border border-gray-300 rounded-lg bg-white text-gray-900 placeholder-gray-400 focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
                      required
                    ></textarea>
                    <button
                      type="submit"
                      class="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors font-medium h-fit"
                    >
                      Post
                    </button>
                  </div>
                </form>
              </div>

              <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-2xl font-bold text-gray-800 mb-4">All Comments</h2>
                <div class="space-y-4">
                  <%= for comment <- @comments do %>
                    <div class="bg-gray-50 rounded-lg p-4">
                      <div class="font-medium text-gray-800 mb-1">{comment.author_name}</div>
                      <div class="text-gray-700 mb-2">{comment.body}</div>
                      <div class="text-sm text-gray-500">
                        On: {comment.post.title} by {comment.post.author.name}
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
        <% end %>
      </div>
    </div>
    """
  end
end
