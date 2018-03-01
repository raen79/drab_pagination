# Pagination

Library that paginates with infinity scroll, sorts and searches. It uses [Drab](https://github.com/grych/drab) library to make back-end requests and manipulate the DOM.

## Installation

The package can be installed by adding `drab_pagination` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:drab_pagination, "~> 0.1.0"}
  ]
end
```

Install the new dependency:
```elixir
$ mix deps.get
```

## Usage

These examples are based on `User` and `Comment` schemas, where a user has many comments.

### Pagination

Use `paginate` to get the paginated query.
```elixir
  def list_paginated_users(%{} = params) do
    paginate(User, params)
  end
  
  # instead of
  def list_users do
    Repo.all(User)
  end
```
Params are `:per_page`, `:page` and `:offset`.

You can also paginate a query accessed through the parent, but don't forget to make the association.
```elixir
def list_paginated_user_comments(%User{} = user, %{} = params) do
  user
    |> Ecto.assoc(:comments)
    |> order_by(desc: :inserted_at) # optional, of course
    |> paginate(params)
end
```

In the controller, access either the function you created in the API or the paginate function. Specify how many items you want to load at once using `:per_page`. `page: 1` and `offset: 0` are used for future iterations, so you should include them too, even if they are obvious.
```elixir
{users, _pagination_params} <- Context.list_paginated_users(%{per_page: 5, page: 1, offset: 0})
```

Note: make sure your controller uses Drab.
```elixir
use Drab.Controller
```

In the commander, include the settings about the queries you want to be paginated in the controller. If your query is generated from the parent (such as the comments of a user, then you need to add :parent_assigns_name, otherwhise not.)
```elixir
use Pagination, [
                  [entries_assigns_name: :users, fetch_entries_func: &Context.list_paginated_users/1],
                  [entries_assigns_name: :comments, parent_assigns_name: :user, fetch_entries_func: &Context.list_paginated_user_comments/2]
                ]
  
  onconnect :onconnect
  ondisconnect :ondisconnect
```
`:entries_assigns_name` and `:parent_assigns_name` are the assigns you give to the structure/changeset. If in the controller you are rendering `users: paginated_users`, then `users` is your `:entries_assigns_name`.
`:fetch_entries_func` is the name function you created in the API to retrieve users. It should start with `&`, and finish with the number of parameters (`/2` if there's a parent, `/1` otherwhise). 

### Sorting

To sort, you still need to have pagination set up.
In addition, if you want to sort, you will need to give your soring options in the controller. The structure should be of a map of key-value pairs, with the string to be displayed as a key, and `{attribute, order}` as value.
```elixir
sorting_dropdown_options = 
    %{
      "Title (A-Z)" => {:title, :asc},
      "Title (Z-A)" => {:title, :desc},
      "Date (Asc)" => {:inserted_at, :asc},
      "Date (Desc)" => {:inserted_at, :desc}
    }
```
If you are using a custom dropdown (using `<li>`'s), you need send a variable containing the current soring option (which is needed for later processing, too).
```elixir
current_sorting_option = "Date (Asc)"
```

#### Templates

You need some HTML to let the user sort. Use this dropdown to display a classic dropdown.
```elixir
<%= Drab_pagination.HTML.sort_by_dropdown(:users, @sorting_dropdown_options) %>
```
If you want to add classes to the dropdown, add the `:class` attribute, like this: `class: "my-class"`
 
If you are using a custom dropdown, the loop printing the options should look similar to this:
```elixir
<%= for {text, _options} <- @sorting_dropdown_options do %>
  <li>
    <a drab-click="sort_users_li" data-order-value="<%= text %>"><%= text %></a>
  </li>
<% end %>
```
Note: The `drab-click` attribute has to be given according to the entries assigns name. The format has to be `sort_[entries_assigns_name]_li`.

### Searching

To sort and search, you still need to have pagination set up.
There's no additions tou need to make in the controller. Your HTML should look like this:

```elixir
<%= Pagination.HTML.search(:users, :title) %>
```
In this example we are searching in `User` using the attribute `title`.

You can add these optional parameters: `:placeholder`, `:class` and `:id`


The docs can be found at [https://hexdocs.pm/drab_pagination](https://hexdocs.pm/drab_pagination).

