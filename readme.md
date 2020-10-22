# Carbon ORM

Carbon is a light-weight ORM for [Fantom](https://fantom.org)

WARNING: under active developement - API **will** change - probably alot 🙂

    conn  := DataConn.makeSqlite(`test.db`)
    store := DataStore(conn)

    store.createTable("users", [
      "id integer PRIMARY KEY",
      "name text NOT NULL",
      "role text NOT NULL"
    ])

    store.q("users").create([
      "name": "Ron Burgundy",
      "role": "lead"
    ])

    u := store.q("users").get(1)
    store.q("users").list.each |r| { echo("${r}") }

