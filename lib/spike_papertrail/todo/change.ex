defmodule SpikePapertrail.Todo.Change do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :event, :item_type, :item_id, :item_changes, :originator_id, :origin, :meta]}
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

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:event, :item_type, :item_id, :item_changes, :originator_id, :origin, :meta])
  end
end
