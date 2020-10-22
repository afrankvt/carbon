//
// Copyright (c) 2020, Andy Frank
// Licensed under the MIT License
//
// History:
//   16 Oct 2020  Andy Frank  Creation
//

using concurrent
using sql
using util

*************************************************************************
** DataStore
*************************************************************************

const class DataStore
{
  ** Construct a new DataStore instance using given 'conn'.
  new make(DataConn conn)
  {
    this.conn = conn
  }

  ** Data connection for this store instance.
  const DataConn conn

  ** Convenience for 'conn.close'.
  Void close() { conn.close }

  ** Return 'true' if table name exists, or 'false' if not.
  Bool tableExists(Str name)
  {
    actor.send(DataMsg("tableExists", name)).get
  }

  ** Create a new table name with given column structure.
  This createTable(Str name, Str[] cols)
  {
    actor.send(DataMsg.makeTable("createTable", name, cols)).get
    return this
  }

  ** Get a query instance for given table.
  DataQuery q(Str table)
  {
    // TODO: cache these; for now just instance new
    // TODO: validate table name against injection attacks
    return DataQuery(this, table)
  }

  private const ActorPool pool := ActorPool { it.name="CarbonDataStore" }
  internal const Actor actor := Actor(pool) |DataMsg m->Obj?|
  {
    // TODO: do we need to choke these through an actor?
    //       or can we open this up? maybe the q() call
    //       spawns off an async worker from const store?

    // trap this first since meta wil not yet be available
    if (m.op == "tableExists")
    {
      return conn.sqlconn.meta.tableExists(m.table)
    }
    else if (m.op == "createTable")
    {
      cols := m.cols.join(",")
      sql  := "create table if not exists ${m.table} (${cols})"
      conn.sqlconn.sql(sql).prepare.execute
      return null
    }

    // TODO: cache this
    meta := DataMeta {
      it.table = m.table
      it.cols  = conn.sqlconn.meta.tableRow(m.table).cols.map |c| { c.name }
    }

    switch (m.op)
    {
      case "get":
        row := conn.sqlconn.sql("select * from ${m.table} where id = @id")
          .prepare
          .query(["id":m.id])
          .first
        return row==null ? null : DataRec(meta, row)

      case "list":
        return conn.sqlconn.sql("select * from ${m.table}")
          .query
          .map |r| { DataRec(meta, r) }.toImmutable

      case "count":
        res := conn.sqlconn.sql("select count(*) from ${m.table}") // where ${b} = @v")
            .prepare
            .query //(["v":c])
        // TODO: this differs by database I think?
        Row row := res->first
        return row.get(row.cols.first)

      case "update":
        cols := m.map.keys.join(",") |n| { "${n} = @${n}" }
        res  := conn.sqlconn.sql("update ${m.table} set ${cols} where id = ${m.id}")
          .prepare
          .execute(m.map)
        return m.id

      case "create":
        // TODO: validate col names against injection attacks
        cols := m.map.keys.join(",")
        vars := m.map.keys.join(",") |n| { "@${n}" }
        res  := conn.sqlconn.sql("insert into ${m.table}(${cols}) values (${vars})")
          .prepare
          .execute(m.map)
        // TODO: this differs by database I think; return id of new rec
        return res->first

      default: return null
    }
  }

//     switch (m.first)
//     {
//       case "recBy":
//         row := conn.sql("select * from ${a} where ${b} = @v")
//           .prepare
//           .query(["v":c])
//           .first
//         return row==null ? null : toRec(a, row)
//
//       case "recs":
//         if (b == "id" && c == -1)
//         {
//           return conn.sql("select * from ${a}")
//             .query
//             .map |r| { toRec(a, r) }.toImmutable
//         }
//         else
//         {
//           return conn.sql("select * from ${a} where ${b} = @v")
//             .prepare
//             .query(["v":c])
//             .map |r| { toRec(a, r) }.toImmutable
//         }
//
//       case "update":
//         Map map := c
//         nv  := map.keys.join(",") |n| { "${n} = @${n}" }
//         res := conn.sql("update ${a} set ${nv} where id = ${b}")
//           .prepare
//           .execute(map)
//         return b
//
//       case "updateBy":
//         Map map := d
//         nv  := map.keys.join(",") |n| { "${n} = @${n}" }
//         cv  := c as Int ?: "'${c}'" // TODO!
//         res := conn.sql("update ${a} set ${nv} where ${b} = ${cv}")
//           .prepare
//           .execute(map)
//         return b
//
//       case "delete":
//         res := conn.sql("delete from ${a} where id = ${b}")
//           .prepare
//           .execute
//         return null
//
//       case "deleteBy":
//         cv  := c as Int ?: "'${c}'" // TODO!
//         res := conn.sql("delete from ${a} where ${b} = ${cv}")
//           .prepare
//           .execute
//         return null
//     }
//     return null
//   }
}

*************************************************************************
** DataMsg
*************************************************************************

internal const class DataMsg
{
  new make(Str op, Str table, Int? id := null, [Str:Obj]? map := null)
  {
    this.op    = op
    this.table = table
    this.id    = id
    this.map   = map
  }

  new makeTable(Str op, Str table, Str[] cols)
  {
    this.op    = op
    this.table = table
    this.cols  = cols
  }

  const Str op
  const Str table
  const Str[]? cols
  const Int? id
  const [Str:Obj]? map
}