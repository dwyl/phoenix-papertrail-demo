defmodule SpikePapertrailWeb.ItemControllerTest do
  use SpikePapertrailWeb.ConnCase

  import SpikePapertrail.TodoFixtures

  @create_attrs %{person_id: 42, status: 0, text: "some text"}
  @create_completed_attrs %{person_id: 0, status: 1, text: "some text"}
  @update_attrs %{person_id: 43, status: 1, text: "some updated text"}
  @invalid_attrs %{person_id: nil, status: nil, text: nil}

  describe "index" do
    test "lists all items", %{conn: conn} do
      conn = get(conn, ~p"/items")
      assert html_response(conn, 200) =~ "todos"
    end

    test "lists items in filter", %{conn: conn} do
      conn = post(conn, ~p"/items", item: @create_attrs)

      # After creating item, navigate to 'all' filter page
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ @create_attrs.text

      # After creating item, navigate to 'active' filter page
      conn = get(conn, ~p"/items/active")
      assert html_response(conn, 200) =~ @create_attrs.text

      # Navigate to 'completed page'
      conn = get(conn, ~p"/items/completed")
      assert !(html_response(conn, 200) =~ @create_attrs.text)
    end
  end

  describe "new action" do
    test "renders index", %{conn: conn} do
      conn = get(conn, ~p"/items/new")
      assert html_response(conn, 200) =~ "todos"
    end
  end

  describe "new item" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/items/new")
      assert html_response(conn, 200) =~ "what needs to be done?"
    end
  end

  describe "create item" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/items", item: @create_attrs)

      assert %{} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/items/"
    end

    test "errors when invalid attributes are passed", %{conn: conn} do
      conn = post(conn, ~p"/items", item: @invalid_attrs)
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end
  end

  describe "edit item" do
    setup [:create_item]

    test "renders form for editing chosen item", %{conn: conn, item: item} do
      conn = get(conn, ~p"/items/#{item}/edit")
      assert html_response(conn, 200) =~ "Click here to create a new item"
    end
  end

  describe "update item" do
    setup [:create_item]

    test "redirects when data is valid", %{conn: conn, item: item} do
      conn = put(conn, ~p"/items/#{item}", item: @update_attrs)
      assert redirected_to(conn) == ~p"/items/"

      conn = get(conn, ~p"/items/")
      assert html_response(conn, 200) =~ "some updated text"
    end

    test "errors when invalid attributes are passed", %{conn: conn, item: item} do
      conn = put(conn, ~p"/items/#{item}", item: @invalid_attrs)
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end
  end

  describe "delete item" do
    setup [:create_item]

    test "deletes chosen item", %{conn: conn, item: item} do
      conn = delete(conn, ~p"/items/#{item}")
      assert redirected_to(conn) == ~p"/items"
    end
  end

  describe "toggle updates the status of an item 0 > 1 | 1 > 0" do
    setup [:create_item]

    test "toggle_status/1 item.status 1 > 0", %{item: item} do
      assert item.status == 0
      # first toggle
      toggled_item = %{item | status: SpikePapertrailWeb.ItemController.toggle_status(item)}
      assert toggled_item.status == 1
      # second toggle sets status back to 0
      assert SpikePapertrailWeb.ItemController.toggle_status(toggled_item) == 0
    end

    test "toggle/2 updates an item.status 0 > 1", %{conn: conn, item: item} do
      assert item.status == 0
      get(conn, ~p'/items/toggle/#{item.id}')
      toggled_item = SpikePapertrail.Todo.get_item!(item.id)
      assert toggled_item.status == 1
    end
  end

  describe "clear completed" do

    test "clears the completed items", %{conn: conn} do
      # Creating completed item
      conn = post(conn, ~p"/items", item: @create_completed_attrs)
      # Clearing completed items
      conn = get(conn, ~p"/items/clear")

      items = conn.assigns.items
      [completed_item | _tail] = conn.assigns.items

      assert conn.assigns.filter == "all"
      assert completed_item.status == 2
    end
  end

  defp create_item(_) do
    item = item_fixture(@create_attrs)
    %{item: item}
  end
end
