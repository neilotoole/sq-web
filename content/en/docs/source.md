---
title: Sources
description: Sources
lead: ''
draft: false
images: []
weight: 1036
toc: true
---
A _source_ is an individual data source, such as a database connection, or
a CSV or Excel document.

A source has three main elements:

- `driver type`: such as `postgres`, or `csv`.
- `handle`: such as `@sakila_pg`. A handle always starts with `@`. The handle is used to refer
  to the data source.
- `location`: such as `postgres://user:p_ssW0rd@@localhost/sakila`. For
  a document source, _location_ may just be a file path, e.g. `/Users/neilotoole/sakila.csv`.

## Add source

To add a source, use `sq add` (see the [`sq add` docs](/docs/cmd/add) for more).

```shell
# Add a postgres database
$ sq add postgres://sakila:p_ssW0rd@localhost/sakila
@sakila_pg  postgres  sakila@localhost/sakila

# Add a CSV source, specifying the handle.
$ sq add ./actor.csv -h @actors
```

## List sources

Use [`sq ls`](/docs/cmd/ls) to list sources.

```shell
$ sq ls
@sakila_sl3*   sqlite3    sakila.db
@sakila_pg9    postgres   sakila@192.168.50.137/sakila
@sakila_pg10   postgres   sakila@192.168.50.140/sakila
```

Note the `*` beside `@sakila_sl3`: this means that it's
the [active source](#active-source).

Pass the `-v` (`--verbose`) flag to see more detail:

```shell
$ sq ls -v
@sakila_sl3*   sqlite3    sqlite3:///Users/neilotoole/sakila.db
@sakila_pg9    postgres   postgres://sakila:xxxxx@192.168.50.137/sakila
@sakila_pg10   postgres   postgres://sakila:xxxxx@192.168.50.140/sakila
```

## Active source

The _active source_ is the source upon which `sq` acts if no other source is specified.

By default, `sq` requires that the first element of a query be the source handle:

```shell
$ sq '@sakila | .actor | .first_name, last_name'

```

But if an active source is set, you can omit the handle:

```shell
$ sq '.actor | .first_name, .last_name'
```

Use [`sq src`](/docs/cmd/src) to get or set the active source.

```shell
# Get active source
$ sq src
@sakila_sl3  sqlite3  sakila.db

# Set active source
$ sq src @sakila_pg12
@sakila_pg12  postgres  sakila@192.168.50.132/sakila
```

## Remove source

Use [`sq rm`](/docs/cmd/rm) to remove a source.

```shell
# Remove a single source.
$ sq rm @sakila_pg

# Remove multiple sources at once.
$ sq rm @sakila_pg @sakila_sqlite
```

## Ping sources

Use [`sq ping`](/docs/cmd/ping) to check the connection status of your sources.

```shell
$ sq ping --all
@sakila_my                           42ms  pong
@sakila_pg9                          64ms  pong
@sakila_pg12                         65ms  pong
@pg_sakila_local                     12ms  fail  failed to connect to `host=localhost user=sakila database=sakila`: dial error (dial tcp 127.0.0.1:5432: connect: connection refused)
@sakila2_xlsx                       560ms  fail  open /Users/neilotoole/sakila2.xlsx: no such file or directory
```







