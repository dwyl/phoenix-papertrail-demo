defmodule SpikePapertrailWeb.ItemController do
  use SpikePapertrailWeb, :controller

  alias SpikePapertrail.Change
  alias SpikePapertrail.Todo
  alias SpikePapertrail.Todo.Item
  import Ecto.Query
  alias SpikePapertrail.Repo

  def index(conn, params) do
    item =
      if not is_nil(params) and Map.has_key?(params, "id") do
        Todo.get_item!(params["id"])
      else
        %Item{}
      end

    items = Todo.list_items()
    changeset = Todo.change_item(item)

    render(conn, "index.html",
      items: items,
      changeset: changeset,
      editing: item,
      filter: Map.get(params, "filter", "all"),
      changes: Change.list_last_20_changes()
    )
  end

  def new(conn, _params) do
    changeset = Todo.change_item(%Item{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"item" => item_params}) do
    case Todo.create_item(item_params) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Item created successfully.")
        |> assign(:changes, Change.list_last_20_changes())
        |> redirect(to: ~p"/items/")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Todo.get_item!(id)
    render(conn, :show, item: item)
  end

  def edit(conn, params) do
    conn = assign(conn, :changes, Change.list_last_20_changes())
    index(conn, params)
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    item = Todo.get_item!(id)

    case Todo.update_item(item, item_params) do
      {:ok, _item} ->
        conn
        |> assign(:changes, Change.list_last_20_changes())
        |> redirect(to: ~p"/items/")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, item: item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Todo.get_item!(id)
    {:ok, _item} = Todo.delete_item(item)

    conn
    |> put_flash(:info, "Item deleted successfully.")
    |> assign(:changes, Change.list_last_20_changes())
    |> redirect(to: ~p"/items")
  end

  def toggle_status(item) do
    case item.status do
      1 -> 0
      0 -> 1
    end
  end

  def toggle(conn, %{"id" => id}) do
    item = Todo.get_item!(id)
    Todo.update_item(item, %{status: toggle_status(item)})

    conn
    |> redirect(to: ~p"/items")
  end

  def clear_completed(conn, _param) do
    person_id = 0
    query = from(i in Item, where: i.person_id == ^person_id, where: i.status == 1)
    Repo.update_all(query, set: [status: 2])
    # render the main template:
    index(conn, %{filter: "items"})
  end
end
