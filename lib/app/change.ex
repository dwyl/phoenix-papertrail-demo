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
