---
title: "SQLite"
description: "SQLite driver"
draft: false
images: []
weight: 4040
toc: false
---
The `sq` Postgres driver implements connectivity for
the [SQLite](https://www.sqlite.org) database.
The driver implements all optional driver features.

## sq add

The location argument is simply the filepath to the SQLite data file.
For example:

```shell
sq add ./sakila.db
```

You can also supply the absolute filepath, or use a URI with the `sqlite3://` prefix.
For example:

```shell
sq add 'sqlite3:///Users/neilotoole/sakila.db'
```

### Create new SQLite DB

You can use `sq` to create a new, empty, SQLite DB file.

```shell
$ sq add --driver sqlite3 hello.db
@hello_sqlite  sqlite3  hello.db
```
