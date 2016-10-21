defmodule RethinkDB.Ecto.Test do
  use ExUnit.Case

  alias Ecto.Integration.TestRepo
  alias RethinkDB.Query, as: ReQL

  defmodule User do
    use Ecto.Schema

    @primary_key {:id, :binary_id, autogenerate: false}

    schema "users" do
      field :name, :string
      field :age, :integer
      field :in_relationship, :boolean
      timestamps
    end
  end

  setup_all do
    User.__schema__(:source)
    |> ReQL.table_create()
    |> TestRepo.run()
    :ok
  end

  setup do
    User.__schema__(:source)
    |> ReQL.table()
    |> ReQL.delete()
    :ok
  end

  test "insert, update and delete user" do
    user_params = %{name: "Mario", age: 26, in_relationship: true}
    {:ok, user} =
      Ecto.Changeset.cast(%User{}, user_params, Map.keys(user_params))
      |> TestRepo.insert
    assert ^user_params = Map.take(user, Map.keys(user_params))
    user_params = Map.put(user_params, :age, 27)
    {:ok, user} =
      Ecto.Changeset.cast(user, user_params, Map.keys(user_params))
      |> TestRepo.update
    assert ^user_params = Map.take(user, Map.keys(user_params))
    {:ok, user} = TestRepo.delete user
    assert ^user_params = Map.take(user, Map.keys(user_params))
  end

  test "insert, update and delete users" do
    assert {3, _} = TestRepo.insert_all User, [%{name: "Mario", age: 26, in_relationship: true},
                                               %{name: "Felix", age: 25, in_relationship: true},
                                               %{name: "Roman", age: 24, in_relationship: true}]
    assert {3, _} = TestRepo.update_all User, set: [in_relationship: false]
    assert {3, _} = TestRepo.delete_all User
  end
end
