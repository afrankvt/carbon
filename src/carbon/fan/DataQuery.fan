//
// Copyright (c) 2020, Andy Frank
// Licensed under the MIT License
//
// History:
//   20 Oct 2020  Andy Frank  Creation
//

*************************************************************************
** DataQuery
*************************************************************************

** DataQuery manages queries to tables for a DataStore.
const class DataQuery
{
  internal new make(DataStore store, Str table)
  {
    this.store = store
    this.table = table
  }

  ** Get record by primary id.
  DataRec? get(Int id)
  {
    store.actor.send(DataMsg("get", table, id)).get
  }

  ** Get the number of records in this table.
  Int count()
  {
    store.actor.send(DataMsg("count", table)).get
  }

  ** List all record in this table.
  DataRec[] list()
  {
    store.actor.send(DataMsg("list", table)).get
  }

  ** Create a new record for this table and return new rec instance.
  DataRec create(Str:Obj map)
  {
    id := store.actor.send(DataMsg("create", table, null, map)).get
    return get(id)
  }

  ** Update an existing record with given primary key, and return
  ** updated rec instance.
  DataRec update(Int id, Str:Obj map)
  {
    store.actor.send(DataMsg("update", table, id, map)).get
    return get(id)
  }

  // TODO: delete

  private const DataStore store
  private const Str table
}
