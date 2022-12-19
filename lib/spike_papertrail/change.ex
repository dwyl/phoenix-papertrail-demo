defmodule SpikePapertrail.Change do
  @moduledoc """
  The Todo context.
  """

  import Ecto.Query, only: [from: 2]
  alias SpikePapertrail.Todo.Change
  alias PaperTrail
  alias SpikePapertrail.Repo

  @doc """
  Returns the list of changes.

  ## Examples

      iex> list_changes()
      [%Change{}, ...]

  """
  def list_last_20_changes do
    from(record in Change, select: record, limit: 20, order_by: [desc: :inserted_at])
    |> Repo.all()
  end
end
