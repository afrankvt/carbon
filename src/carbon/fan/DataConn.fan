//
// Copyright (c) 2020, Andy Frank
// Licensed under the MIT License
//
// History:
//   16 Oct 2020  Andy Frank  Creation
//

using sql
using [java] java.lang::Class as JClass

*************************************************************************
** DataConn
*************************************************************************

** DataConn models a connection to a SQL database for a DataStore.
abstract const class DataConn
{
  ** Return a new DataConn instance for the given sqlite database file.
  static DataConn makeSqlite(File dbfile)
  {
    // preload jdbc driver
    JClass.forName("org.sqlite.JDBC")
    sc := SqlConn.open("jdbc:sqlite:${dbfile.osPath}", null, null)
    return SqlDataConn(sc)
  }

  ** Close this connection or do nothing if already closed.
  abstract Void close()

  // framework use only
  @NoDoc abstract SqlConn sqlconn()
}

*************************************************************************
** SqlDataConn
*************************************************************************

internal const class SqlDataConn : DataConn
{
  new make(SqlConn conn) { this.connRef = Unsafe(conn) }
  override Void close() { sqlconn.close }
  override SqlConn sqlconn() { connRef.val }
  private const Unsafe connRef := Unsafe(null)
}
