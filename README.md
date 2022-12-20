<div align="center">

# `Phoenix` + `PaperTrail` _`Demo`_

A showcase of using `PaperTrail` 
in a simple `Phoenix` Todo List App.

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/dwyl/phoenix-papertrail-demo/ci.yml?label=build&style=flat-square&branch=main)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/phoenix-papertrail-demo/master.svg?style=flat-square)](http://codecov.io/github/dwyl/phoenix-papertrail-demo?branch=master)
[![HitCount](https://hits.dwyl.com/dwyl/phoenix-papertrail-demo.svg?style=flat-square&show=unique)](http://hits.dwyl.com/dwyl/phoenix-papertrail-demo)


[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square)](https://github.com/dwyl/phoenix-papertrail-demo/issues)


![final](https://user-images.githubusercontent.com/17494745/208715527-78c18229-a1f8-4a88-8763-109e1f972104.gif)


</div>
<br />

# Why? 🤷‍

We need a way of capturing the history of `items` in our `App`
to enable "undo" functionality.

# What? 💭

`PaperTrail`: 
[github.com/izelnakri/paper_trail](https://github.com/izelnakri/paper_trail)
Lets you track and record all the changes in your database
and revert back to anytime in history.

This repo demos using `PaperTrail` in a simple Todo List.

# Who? 👤

This quick demo is aimed at people in the @dwyl team
who need to understand how `PaperTrail` is used in our `App`.

# _How_? 👩‍💻

## Prerequisites? 📝

This `Demo` builds upon the foundational work done
in our **`Phoenix` Todo List Tutorial**:
[dwyl/**phoenix-papertrail-demo**](https://github.com/dwyl/phoenix-papertrail-demo)
it is 
[_assumed knowledge_](https://en.wikipedia.org/wiki/Curse_of_knowledge). 

If you haven't been through it,
we suggest taking a few minutes 
to get up-to-speed.

You should also be using Phoenix 1.7+,
as we will use TailwindCSS in this tutorial
to style the UI.

## 1. Borrow Baseline Code

Let's start by cloning the code from
[dwyl/**phoenix-todo-list-tutorial**].
We are going to be using a version of the repo
that does not have authentication nor API.
This is to simplify the workflow 
and testing.

We are going to be using this version:

https://github.com/dwyl/phoenix-todo-list-tutorial/tree/ab4470d68f64ed8f5596dd09f3322193317b838e.

You can also find the initial version 
of this project in the following link:

https://github.com/dwyl/phoenix-papertrail-demo/tree/430e5626d4b8dc15a7d76d4fbae61fed5094f6a8.

In here, you can clone the files
with the same initial version
we are going to be starting this tutorial.

Just make sure these files 
look like the following:
- [`/test/app_web/controllers/item_controller_test.exs`](https://github.com/dwyl/phoenix-papertrail-demo/blob/6116a99190d348c9f87b883ef5525e7921fd034f/test/app_web/controllers/item_controller_test.exs)
- [`/test/app/todo_test.exs`](https://github.com/dwyl/phoenix-papertrail-demo/blob/6116a99190d348c9f87b883ef5525e7921fd034f/test/app/todo_test.exs)
- [`/test/app_web/controllers/item_html_test.exs`](https://github.com/dwyl/phoenix-papertrail-demo/blob/6116a99190d348c9f87b883ef5525e7921fd034f/test/app_web/controllers/item_html_test.exs)
- [`/lib/app_web/router.ex`](https://github.com/dwyl/phoenix-papertrail-demo/blob/6116a99190d348c9f87b883ef5525e7921fd034f/lib/app_web/router.ex)
- [`/lib/app_web/controllers/item_controller.ex`](https://github.com/dwyl/phoenix-papertrail-demo/blob/6116a99190d348c9f87b883ef5525e7921fd034f/lib/app_web/controllers/item_controller.ex)


After cloning the code,
run the following commands to fetch the dependencies
and to set up databases.

```sh
mix deps.get
mix setup
```

After this, if you run `mix phx.server`,
you will be able to run the application.

![original_demo](https://user-images.githubusercontent.com/17494745/208668028-ddcb9e2b-e856-4544-98ce-2e0a98f79c0c.gif)

As you can see, it's a simple todo-list application.

## 2. Installing `PaperTrail`

We want to **see the changes made by the user**
when interacting with its todo items.
As it stands, we have a simple `items` database table
in which the items are saved.
You can check the fields that are persisted in
`lib/app/todo/item.ex`.

```elixir
  schema "items" do
    field :person_id, :integer, default: 0
    field :status, :integer, default: 0
    field :text, :string

    timestamps()
  end
```

To track changes to items within a table,
we are going to be using 
[`PaperTrail`](https://github.com/izelnakri/paper_trail).

Let's start by installing it.
Inside `mix.exs`,
add the following line to the list of dependencies.

```elixir
def deps do
[
  ...
  {:paper_trail, "~> 0.14.3"}
]
end
```

We need to change `PaperTrail`'s configuration
inside `config/config.exs`.
We need to let `PaperTrail` know
the reference of the database repo
so it can save the changes correctly.

Open `config/config.exs` and add the following:

```elixir
config :paper_trail, repo: App.Repo
```

After this, run the following two commands.
It will fetch the `PaperTrail` dependency 
and recompile the project with the configuration we just added.

```sh
mix deps.get
mix compile
```

After this, we will run the following:

```sh
mix papertrail.install
```

The terminal will print the following information.

```sh
* creating priv/repo/migrations
* creating priv/repo/migrations/20221220130334_add_versions.exs
```

A migration is created. 
This file, upon execution, 
will create the table where the changes will be recorded.
Let's give it a closer look!

### 2.1. Analysing the table migration
Here is what you should see in
`priv/repo/migrations`. 

```elixir
defmodule Repo.Migrations.AddVersions do
  use Ecto.Migration

  def change do
    create table(:versions) do
      add :event,        :string, null: false, size: 10
      add :item_type,    :string, null: false
      add :item_id,      :integer
      add :item_changes, :map, null: false
      add :originator_id, references(:users) # you can change :users to your own foreign key constraint
      add :origin,       :string, size: 50
      add :meta,         :map
      
      # Configure timestamps type in config.ex :paper_trail :timestamps_type
      add :inserted_at,  :utc_datetime, null: false
    end

    create index(:versions, [:originator_id])
    create index(:versions, [:item_id, :item_type])
    # Uncomment if you want to add the following indexes to speed up special queries:
    # create index(:versions, [:event, :item_type])
    # create index(:versions, [:item_type, :inserted_at])
  end
end
```

As we can see, several fields are created
in a table called `"versions"`.
You can find the details of each one in 
https://github.com/izelnakri/paper_trail#papertrailversion-fields.
We are going to be focusing on the following five:

- **event**: either "insert", "update" or "delete" operation
- **item_type**: model name of the mutated record (in our case, it's `item`)
- **item_id**: the `id` of the changed record. 
- **item_changes**: `json` object with the changed fields
- **originator_id**: foreign key referencing the creator of the change. 
This is usually a `user` in a `Users` table. 
We don't have this, so we are just going to reference
the `Items` table.

> `item_type`, `item_id` and `item_changes` are called `item`
*by default*, not because our table is called `Item`.
**It is pure coincidence**. 

### 2.2 Creating `versions` table

Before executing the generated migration,
we are going to change the `originator_id` 
reference from `users` 
(this table doesn't exist)
to `items`.

```elixir
  add :originator_id, references(:items) # you can change :users to your own foreign key constraint
```

If you now run `mix ecto.migrate`,
the table `versions` should be created.
The terminal will output these lines:

```sh
13:46:48.334 [info] == Running 20221220130334 Repo.Migrations.AddVersions.change/0 forward

13:46:48.337 [info] create table versions

13:46:48.346 [info] create index versions_originator_id_index

13:46:48.349 [info] create index versions_item_id_item_type_index

13:46:48.354 [info] == Migrated 20221220130334 in 0.0s
```

If you check the tables 
using [DBeaver](https://dbeaver.io/),
you will note that a `versions` table
is created with the specified fields.

<img width="478" alt="dbeaver" src="https://user-images.githubusercontent.com/17494745/208683150-849c7050-16e1-49af-8dca-edce074d1dfc.png">

> DBeaver is a PostgreSQL GUI. 
If you don't have this installed, 
[we *highly recommend you doing so*.](https://github.com/dwyl/learn-postgresql/issues/43#issuecomment-469000357)

## 3. Making `PaperTrail` handle mutations

We are ready to track these changes!
According to [`PaperTrail documentation`](https://github.com/izelnakri/paper_trail#example),
only the `insert`, `update` and `delete` methods
are trackable.
For this, we just need to make `Repo` operations
*pass through `PaperTrail`*.

Head on to `lib/app/todo.ex` 
and do just that!
Import `PaperTrail`
and change the `create_item/1`,
`updated_item/2` 
and `delete_item/1` functions
to the following.

```elixir
defmodule App.Todo do
  alias PaperTrail

  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> PaperTrail.insert()
  end

  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> PaperTrail.update()
  end

  def delete_item(%Item{} = item) do
    PaperTrail.delete(item)
  end

end
```

Instead of calling `Repo.insert()`, for example,
we are using `PaperTrail.insert()` method,
which will handle tracking the changes
for us.

Do notice these operations
will now return a different object.
For example, on success, the return will be:

```elixir
{:ok,
  %{
    model: %Item{__meta__: Ecto.Schema.Metadata<:loaded, "items"> ...},
    version: %PaperTrail.Version{__meta__: Ecto.Schema.Metadata<:loaded, "versions">...}  
  }
}
```

It now returns the `changeset` 
inside `:model` 
and the referring `versions` record
inside `:version`.

If you run `mix phx.server`
and visit `localhost:4000`,
the app should work normally.

<img width="1095" alt="with_papertrail" src="https://user-images.githubusercontent.com/17494745/208689155-e3a4deaa-e318-4a34-9219-30072c597a21.png">

However, every time the user 
creates an item,
edits an item
or deletes one,
this *action is recorded*.

### 3.1 Fixing tests

If you run `mix test`, 
you will notice we broke quite a few tests. 😅

```sh
Finished in 0.2 seconds (0.08s async, 0.1s sync)
32 tests, 14 failures

Randomized with seed 149737
```

Do not worry, though!
We can fix it!
The reason these tests are failing 
is because of what we said earlier:
the object returned from the repo
operation is no longer a `changeset`
but a **map** with `{model: changeset, version: version_obj}`.

Many of these tests is using the `item_fixture/1`
function inside `test/support/fixtures/todo_fixtures.ex`.
If instead of returning the map, 
we return the `:model` property,
most of these failing tests should be corrected!

Open the file and change the function to this:

```elixir
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        person_id: 42,
        status: 42,
        text: "some text"
      })
      |> App.Todo.create_item()

    Map.get(item, :model)
  end
```

If we run `mix test`:

```sh
Finished in 0.2 seconds (0.09s async, 0.1s sync)
32 tests, 3 failures
```

We still got three tests to fix!
Luckily, it's also really simple!
Open the `test/app/todo_test.exs`
and change the following tests to.

```elixir
test "create_item/1 with valid data creates a item" do
  valid_attrs = %{person_id: 42, status: 42, text: "some text"}

  assert {:ok, ret} = Todo.create_item(valid_attrs)
  item = ret.model
  assert item.person_id == 42
  assert item.status == 42
  assert item.text == "some text"
end

test "update_item/2 with valid data updates the item" do
  item = item_fixture()
  update_attrs = %{person_id: 43, status: 43, text: "some updated text"}

  assert {:ok, ret} = Todo.update_item(item, update_attrs)
  item = ret.model
  assert item.person_id == 43
  assert item.status == 43
  assert item.text == "some updated text"
end    
  
test "delete_item/1 deletes the item" do
  item = item_fixture()
  assert {:ok, %{model: %Item{}, version: %PaperTrail.Version{}}} = Todo.delete_item(item)
  assert_raise Ecto.NoResultsError, fn -> Todo.get_item!(item.id) end
end
```

We are now checking the changeset
with `item = ret.model`,
because the object returned 
from database operations have changed
since we are now using `PaperTrail`.

If we run `mix test`:

```sh
................................
Finished in 0.3 seconds (0.1s async, 0.2s sync)
32 tests, 0 failures
```

Everything is fixed! 
Hurray! 🎉

## 4. Showing changes to item in UI

So far, we can check these changes *internally*.
But it would be great to have the ability
to see the changes an `item` has been subjected to
by double-clicking them.

This is the "hardest" part of the tutorial
but it will be well worth it!

### 4.1 Fetching last `changes` of an `item`

[`PaperTrail` has a way to fetch the 
`last` and `first`](https://github.com/dwyl/phoenix-papertrail-demo/blob/6116a99190d348c9f87b883ef5525e7921fd034f/lib/app_web/controllers/item_controller.ex) `version` 
(the name of the change record inside `versions` table)
but no way of querying multiple or even filtering.
We will need to do that job ourselves.

For this, we are going to add a `Changes` schema
that will be then displayed on the UI.

inside `lib/app/todo`, create a file `change.ex`
and add the following code.

```elixir
defmodule App.Todo.Change do
  use Ecto.Schema

  schema "versions" do
    field :event,        :string
    field :item_type,    :string
    field :item_id,      :integer
    field :item_changes, :map
    field :originator_id, :integer
    field :origin,       :string
    field :meta, :map
    field :inserted_at, :naive_datetime
  end
end
```

We just added the same fields that are present
inside the `versions` table. 

Inside `lib/app`, add a new file `change.ex`.
Inside this file, 
we are going to add the function `list_last_20_changes/1`.
This function will return the last 20 changes
made on a given `item`.

```elixir
defmodule App.Change do
  @moduledoc """
  The Todo context.
  """

  import Ecto.Query, only: [from: 2]
  alias App.Todo.Change
  alias PaperTrail
  alias App.Repo

  @doc """
  Returns the list of changes for a specific item.

  ## Examples

      iex> list_changes(12)
      [%Change{}, ...]

  """
  def list_last_20_changes(id) do
    from(record in Change, where: record.item_id == ^id, select: record, limit: 20, order_by: [desc: :inserted_at])
    |> Repo.all()
  end
end
```

### 4.2 Adding list of changes to connection assigns

To show an `item`'s changes in the UI,
we need to make it available inside the view controller.
Currently, to edit an `item`, we double-click it.

<img width="1095" alt="update" src="https://user-images.githubusercontent.com/17494745/208703895-4c20b3a9-d0a0-48e5-bc4f-91cad2a05221.png">

We can leverage this behaviour 
to also show the actions next to it.
When editing a timer, 
the `index` function is called
inside `lib/app/controllers/item_controller.ex`.
Whenever an `id` is in the URL params, 
it means an item is being edited.
Therefore, we can add a `changes` array
to the connection assigns 
referring to the tracking changes of the `item` 
that is being edited.

Inside `item_controller.ex`, 
change the `index/2` function to the following.

```elixir
  def index(conn, params) do
    item =
      if not is_nil(params) and Map.has_key?(params, "id") do
        Todo.get_item!(params["id"])
      else
        %Item{}
      end

    changes = case Map.has_key?(params, "id") do
      true ->
        Change.list_last_20_changes(params["id"])

      false -> []
    end

    items = Todo.list_items()
    changeset = Todo.change_item(item)

    render(conn, "index.html",
      items: items,
      changeset: changeset,
      editing: item,
      filter: Map.get(params, "filter", "all"),
      changes: changes
    )
  end
```

We are now fetching the `item` changes 
every time it is being edited!

### 4.3 Changing the UI

Now that we have the changes array
assigned to the connection assigns,
we can use them in our UI!

Since we are using Phoenix 1.7rc,
it has TailwindCSS installed by default.
So we can use it!

Find the `lib/app_web/controllers/item_html/index.html.heex` 
file and make the following changes.
Locate `<section class="todoapp">`
and change it to:

```html
<section class="todoapp h-fit w-[100%] mb-12 md:w-[50%] md:mb-0 md:ml-2">
```

Now wrap all the contents of the file in a `<div>`
with the following classes.

```html
<div class='w-full flex flex-col md:flex-row md:justify-around'>
  <section></section>
  <!-- adding a section here -->
</div>
```

We are creating two flex columns:
one for the section pertaining to adding/editing/deleting items
(what we already have)
and another section to showcase the changes of the item
(what we are going to build).

Inside the wrapper `div` we have created,
add a second section, 
next to the already existing one.
*This will be the section displaying the changes*.

Add the following code:

```html
  <section class="max-w-full md:w-[50%]">
    <header class="header mt-12">
      <h1 class="text-5xl text-center text-[#af2f2f26]">Actions</h1>
      <h3 class="text-lg text-center text-[#af2f2f9f]">last 20 actions of chosen item</h3>
    </header>
    <div class="mt-12 pr-1 pl-4">
      <%= for change <- @changes do %>
      <div class="mb-4">
        <div>
          <span class="text-blue-500	"><b>event:</b> <%= change.event %></span>
          <span class='ml-2 mr-2'>|</span>
          <span><b>type:</b> <%= change.item_type %></span>
          <span class='ml-2 mr-2'>|</span>
          <span><b>item_id:</b> <%= change.item_id %></span>
        </div>
        <div>
          <span class="text-xs"><b>item_changes:</b> <%= inspect(Map.take(change.item_changes, ["inserted_at", "status", "text"]))%></span>
        </div>
      </div>
      <% end %>
    </div>
  </section>
```

Here we are iterating over the `@changes` array
inside the connection assigns
and displaying the information to the user.

The last change we need to do is to
remove the `width` constraints of the `body` 
in the `assets/css/todomvc-app.css` file.
Locate `body {}` 
and delete `min-width` and `max-width` fields.
It should now look like this.

```css
body {
	font: 14px 'Helvetica Neue', Helvetica, Arial, sans-serif;
	line-height: 1.4em;
	background: #f5f5f5;
	color: #4d4d4d;
	margin: 0 auto;
	-webkit-font-smoothing: antialiased;
	-moz-osx-font-smoothing: grayscale;
	font-weight: 300;
}
```

If you run `mix phx.server`, 
your app should now be working!

![final](https://user-images.githubusercontent.com/17494745/208715527-78c18229-a1f8-4a88-8763-109e1f972104.gif)


### 4.4 Running tests

If we run `MIX_ENV=test mix coveralls.html`, 
we will observe this output:

```sh
................................
Finished in 0.2 seconds (0.08s async, 0.1s sync)
32 tests, 0 failures

Randomized with seed 852095
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/app/change.ex                              24        1        0
100.0% lib/app/todo.ex                               112        7        0
100.0% lib/app/todo/change.ex                         15        1        0
100.0% lib/app/todo/item.ex                           19        2        0
100.0% lib/app_web/controllers/error_html.ex          19        1        0
100.0% lib/app_web/controllers/error_json.ex          15        1        0
100.0% lib/app_web/controllers/item_controller.      106       34        0
100.0% lib/app_web/controllers/item_html.ex           40       12        0
  0.0% lib/app_web/gettext.ex                         24        0        0
100.0% lib/app_web/router.ex                          27        5        0
[TOTAL] 100.0%
```

That's right! No need to add new tests!
We fixed all of them prior.
This shows that integrating `PaperTrail` 
into your project should have minimal impact
and you can quickly get up-and-running 
with a few lines of code!

## 5. Adding further information on `version` records

We touched on a basic usage of `PaperTrail`
in this walk-through.
However, there are a handful of features
that might be useful for other use-cases
to add extra information to each 
`change` record.

### 5.1 Version origin references

Amongst the fields in the `versions` schema,
there is one called `origin`. 
The user can add a string 
pertaining to the origin of the mutation.

```elixir
PaperTrail.update(changeset, origin: "migration")
```

### 5.2 Adding metadata

Similarly, there is a `meta` field
in which metadata can be added. 

```elixir
PaperTrail.update(changeset, meta: %{data: "some data"})
```

There are more advanced features that can be used
(e.g. multi-tenancy).
You can find more about these
in the [`PaperTrail docs`](https://github.com/izelnakri/paper_trail)
