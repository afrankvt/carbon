//
// Copyright (c) 2020, Andy Frank
// Licensed under the MIT License
//
// History:
//   20 Oct 2020  Andy Frank  Creation
//

using sql

*************************************************************************
** DataRec
*************************************************************************

** DataRec models a database record.
const class DataRec
{
  ** Internal ctor.
  internal new make(DataMeta meta, Row row)
  {
    this.meta   = meta
    this.unsafe = Unsafe(row)
  }

  ** Table and column meta data.
  const DataMeta meta

  ** Get the record id.
  Int id() { row->id }

  ** Get the record value for the 'name', or null if not found.
  Obj? get(Str name)
  {
    c := row.col(name, false)
    return c == null ? null : row.get(c)
  }

  ** Convenience for `get`.
  override Obj? trap(Str name, Obj?[]? val := null)
  {
    get(name)
  }

  override Str toStr()
  {
    buf := StrBuf()
    buf.add("${meta.table}: {")
    meta.cols.each |c| { buf.add(" ${c}:${get(c)}") }
    buf.add(" }")
    return buf.toStr
  }

  // TODO: is this safe? do we just make our own copy?
  internal Row row() { unsafe.val }
  internal const Unsafe unsafe
}
