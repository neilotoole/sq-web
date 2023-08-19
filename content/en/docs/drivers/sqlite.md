---
title: "SQLite"
description: "SQLite driver"
draft: false
images: []
weight: 4040
toc: false
url: /docs/drivers/sqlite
---
The `sq` SQLite driver implements connectivity for
the [SQLite](https://www.sqlite.org) database.
The driver implements all optional driver features.

## Add source

Use [`sq add`](/docs/cmd/add) to add a source. The location argument is simply the
filepath to the SQLite DB file. For example:

```shell
sq add ./sakila.db
```

You can also supply the absolute filepath, or use a URI with the `sqlite3://` prefix.
For example:

```shell
$ sq add /Users/neilotoole/sakila.db
$ sq add 'sqlite3:///Users/neilotoole/sakila.db'
```

`sq` usually can detect that a file is a SQLite datafile, but in the event
it doesn't, you can explicitly specify the driver type:

```shell
$ sq add --driver=sqlite3 ./sakila.db
```

### Create new SQLite DB

You can use `sq` to create a new, empty, SQLite DB file.

```shell
$ sq add --driver sqlite3 hello.db
@hello  sqlite3  hello.db
```
