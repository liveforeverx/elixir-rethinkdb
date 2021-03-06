defmodule Rethinkdb.Rql.Test do
  use Rethinkdb.Case, async: false
  use Rethinkdb

  alias Rethinkdb.Connection

  test "defines a terms to generate a ql2 terms" do
    rql  = r.expr(1)
    term = QL2.Term.new(type: :'DATUM', datum: QL2.Datum.from_value(1))
    assert term == rql.build
  end

  test "defines a run to forward Connection.run" do
    mocks = [
      connect!: fn _ -> {Connection} end,
      run: fn QL2.Term[] = term, {Connection} -> {:ok, term} end,
      run!: fn QL2.Term[] = term, {Connection} -> term end
    ]
    with_mock Connection, mocks do
      conn = r.connect
      assert {:ok, r.expr(1).build} == r.expr(1).run(conn)
      assert r.expr(1).build == r.expr(1).run!(conn)
    end
  end

  test "use default connection to execute a query" do
    assert {:ok, 10} == r.expr(10).run
    assert 10 == r.expr(10).run!
  end

  test "accept uri as parameters in connect" do
    conn = r.connect(default_options.to_uri)
    assert default_options == conn.options
    assert conn.open?
    conn.close
  end

  test "accept options as parameters in connect" do
    conn = r.connect(default_options)
    assert default_options == conn.options
    assert conn.open?
    conn.close
  end

  test "return a connection record" do
    conn = r.connect(default_options)
    assert is_record(conn, Rethinkdb.Connection)
    assert conn.open?
    conn.close
  end

  #test "run concurrent queries" do
    #my   = self
    #spawn(fn -> my <- r.js("while(true) {}", timeout: 1).run end)
    #spawn(fn -> my <- r.js("10").run end)
    #assert {:ok, 10} == receive(do: (any -> any))
    #{:error, _, _, _} = receive(do: (any -> any))
  #end
end

