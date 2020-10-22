//
// Copyright (c) 2020, Andy Frank
// Licensed under the MIT License
//
// History:
//   21 Oct 2020  Andy Frank  Creation
//

*************************************************************************
** DataMeta
*************************************************************************

const class DataMeta
{
  ** Internal ctor.
  internal new make(|This| f) { f(this) }

  ** Table name for this instance.
  const Str table

  ** Column names for this table.
  const Str[] cols
}