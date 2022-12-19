defmodule SpikePapertrail.TodoTest do
  use SpikePapertrail.DataCase

  alias SpikePapertrail.Todo

  describe "items" do
    alias SpikePapertrail.Todo.Item

    import SpikePapertrail.TodoFixtures

    @invalid_attrs %{person_id: nil, status: nil, text: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Todo.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Todo.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      valid_attrs = %{person_id: 42, status: 42, text: "some text"}

      assert {:ok, %{model: %Item{}, version: %PaperTrail.Version{}} = ret} = Todo.create_item(valid_attrs)
      item = ret.model
      assert item.person_id == 42
      assert item.status == 42
      assert item.text == "some text"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todo.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{person_id: 43, status: 43, text: "some updated text"}

      assert {:ok, item} = Todo.update_item(item, update_attrs)
      item = item.model
      assert item.person_id == 43
      assert item.status == 43
      assert item.text == "some updated text"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Todo.update_item(item, @invalid_attrs)
      assert item == Todo.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %{model: %Item{}, version: %PaperTrail.Version{}}} = Todo.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Todo.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Todo.change_item(item)
    end
  end
end
