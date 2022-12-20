defmodule App.Todo.Change do
  use Ecto.Schema
  import Ecto.Changeset

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
