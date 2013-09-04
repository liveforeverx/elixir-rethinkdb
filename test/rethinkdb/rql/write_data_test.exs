defmodule Rethinkdb.Rql.WriteData.Test do
  use Rethinkdb.Case, async: false
  use Rethinkdb

  setup_all do
    {conn, table} = connect("marvel")
    {:ok, conn: conn, table: table }
  end

  test "insert list of tuple in table", var do
    {conn, table} = {var[:conn], var[:table]}

    data   = [superhero: "Iron Man", superpower: "Arc Reactor"]
    result = r.table(table).insert(data).run!(conn)
    assert 1 == result[:inserted]
    assert 1 == length(result[:generated_keys])
  end

  test "insert hashdict in table", var do
    {conn, table} = {var[:conn], var[:table]}

    data   = HashDict.new(superhero: "Ciclope", superpower: "Optic Blast")
    result = r.table(table).insert(data).run!(conn)
    assert 1 == result[:inserted]
    assert 1 == length(result[:generated_keys])
  end

  test "insert a multiples hashs", var do
    {conn, table} = {var[:conn], var[:table]}

    data = [
      [ superhero: "Wolverine", superpower: "Adamantium" ],
      HashDict.new(superhero: "Spiderman", superpower: "spidy sense")
    ]
    result = r.table(table).insert(data, durability: :soft).run!(conn)
    assert 2 == result[:inserted]
    assert 2 == length(result[:generated_keys])
  end

  test "insert a list of tuple and return data", var do
    {conn, table} = {var[:conn], var[:table]}

    data   = HashDict.new(superhero: "Mystique", superpower: "Metamorphoses")
    result = r.table(table).insert(data, return_vals: true).run!(conn)

    new_val = result[:new_val]
    assert data[:superhero] == new_val[:superhero]
    assert data[:superpower] == new_val[:superpower]
  end

  test "insert and overwriting", var do
    {conn, table} = {var[:conn], var[:table]}
    table   = r.table(table)
    data    = HashDict.new(superhero: "Hulk", superpower: "Greenish")
    result  = table.insert(data, return_vals: true).run!(conn)

    result = table.insert(result[:new_val], upsert: true, return_vals: true).run!(conn)
    assert 1 == result[:unchanged]

    new_val = Dict.put(result[:new_val], :superpower, "Super Strength")

    result = table.insert(new_val, upsert: true, return_vals: true).run!(conn)
    assert 1 == result[:replaced]
    assert data[:superpower] == result[:old_val][:superpower]
    assert new_val[:superpower] == result[:new_val][:superpower]
  end
end