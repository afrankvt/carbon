//
// Copyright (c) 2020, Andy Frank
// Licensed under the MIT License
//
// History:
//   16 Oct 2020  Andy Frank  Creation
//

*************************************************************************
** BasicTest
*************************************************************************

class BasicTest : Test
{
  DataConn testConn()
  {
    file := Env.cur.tempDir + `test.db`
    /*if (!file.exists) */file.create
    return DataConn.makeSqlite(file)
  }

  Void testBasics()
  {
    conn  := testConn
    store := DataStore(conn)

    verifyFalse(store.tableExists("users"))

    store.createTable("users", [
      "id integer PRIMARY KEY",
      "name text NOT NULL",
      "role text NOT NULL"
    ])

    verifyTrue(store.tableExists("users"))

    users := store.q("users")
    users.create(["name":"Ron Burgundy",          "role":"lead"])
    users.create(["name":"Veronica Corningstone", "role":"lead"])
    users.create(["name":"Brian Fantana",         "role":"sports"])
    users.create(["name":"Brick Tamland",         "role":"weather"])

    echo("> users [${users.count}]")
    users.list.each |r| { echo("  ${r}") }


    users.update(3, ["role":"fired"])
    echo(users.get(3))
  }
}