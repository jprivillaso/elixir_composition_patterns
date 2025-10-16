# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElxirComposition.Repo.insert!(%ElxirComposition.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ElxirComposition.Repo
alias ElxirComposition.Blog
alias ElxirComposition.Blog.{Author, Post, Comment}

# Clear existing data
Repo.delete_all(Comment)
Repo.delete_all(Post)
Repo.delete_all(Author)

IO.puts("Creating authors...")

{:ok, alice} =
  Blog.create_author(%{
    name: "Alice Johnson",
    email: "alice@example.com",
    bio: "Elixir enthusiast and functional programming advocate"
  })

{:ok, bob} =
  Blog.create_author(%{
    name: "Bob Smith",
    email: "bob@example.com",
    bio: "Phoenix framework expert"
  })

{:ok, carol} =
  Blog.create_author(%{
    name: "Carol Williams",
    email: "carol@example.com",
    bio: "Database optimization specialist"
  })

IO.puts("Creating posts...")

{:ok, post1} =
  Blog.create_post(alice.id, %{
    title: "Introduction to Ecto Query Composition",
    body: "Learn how to build complex queries by composing simple functions..."
  })

Blog.publish_post(post1)

{:ok, post2} =
  Blog.create_post(alice.id, %{
    title: "Advanced Phoenix Patterns",
    body: "Exploring advanced patterns in Phoenix applications..."
  })

Blog.publish_post(post2)

{:ok, post3} =
  Blog.create_post(bob.id, %{
    title: "Building Real-Time Features",
    body: "How to implement real-time features with LiveView..."
  })

Blog.publish_post(post3)

{:ok, post4} =
  Blog.create_post(carol.id, %{
    title: "Database Performance Tips",
    body: "Optimize your Ecto queries for better performance..."
  })

Blog.publish_post(post4)

{:ok, post5} =
  Blog.create_post(alice.id, %{
    title: "Testing Elixir Applications",
    body: "Best practices for testing Elixir and Phoenix apps..."
  })

Blog.publish_post(post5)

# Create a draft post (not published)
Blog.create_post(bob.id, %{
  title: "Draft: Upcoming Features",
  body: "This is a draft post that hasn't been published yet..."
})

IO.puts("Creating comments...")

Blog.create_comment(post1.id, %{
  author_name: "David Lee",
  body: "Great introduction! Very helpful for beginners."
})

Blog.create_comment(post1.id, %{
  author_name: "Emma Davis",
  body: "Could you provide more examples of complex compositions?"
})

Blog.create_comment(post1.id, %{
  author_name: "Frank Miller",
  body: "This helped me understand query composition better!"
})

Blog.create_comment(post2.id, %{
  author_name: "Grace Chen",
  body: "Excellent article on Phoenix patterns!"
})

Blog.create_comment(post3.id, %{
  author_name: "Henry Wilson",
  body: "LiveView is amazing! Thanks for the tutorial."
})

Blog.create_comment(post3.id, %{
  author_name: "Isabel Martinez",
  body: "Can't wait to implement this in my project."
})

Blog.create_comment(post4.id, %{
  author_name: "Jack Brown",
  body: "These performance tips saved my app!"
})

Blog.create_comment(post5.id, %{
  author_name: "Karen Taylor",
  body: "Testing strategies are solid. Thank you!"
})

IO.puts("\nSeeding complete!")
IO.puts("Created:")
IO.puts("  - #{Blog.count_authors()} authors")
IO.puts("  - #{Blog.count_posts()} total posts")
IO.puts("  - #{Blog.count_published_posts()} published posts")
IO.puts("  - #{Blog.count_comments()} comments")
