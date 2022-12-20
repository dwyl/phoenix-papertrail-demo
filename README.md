# `Phoenix` + `PaperTrail` _`SPIKE`_

A showcase of using `PaperTrail` in a simple `Phoenix` Todo List App.

# Why?

We need a way of capturing the history of `items` in our `App`
to enable "undo" functionality.

# What?

`PaperTrail`: 
[github.com/izelnakri/paper_trail](https://github.com/izelnakri/paper_trail)
Lets you track and record all the changes in your database
and revert back to anytime in history.

This repo demos using `PaperTrail` in a simple Todo List.

# Who?

This quick demo is aimed at people in the @dwyl team
who need to understand how `PaperTrail` is used in our `App`.

# _How_?

## Prerequisites? 

This `Spike` builds upon the foundational work done
in our `Phoenix` Todo List Tutorial:
[dwyl/**phoenix-todo-list-tutorial**](https://github.com/dwyl/phoenix-todo-list-tutorial)

If you haven't been through it,
we suggest taking a few minutes to get up-to-speed.

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


# _Deploy_!

Bonus level: deploy to **Fly.io** 
so that anyone can try it.
