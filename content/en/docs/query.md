---
title: "Query Language"
description: "Query Language Reference"
lead: ""
draft: false
images: []
weight: 1035
toc: true
---
`sq` implements a [`jq`](https://stedolan.github.io/jq/)-style query language, formally
known as [`SLQ`](https://github.com/neilotoole/sq/tree/master/grammar).

Behind the scenes, all `sq` queries execute against a SQL database. This is true even for
[document sources](/docs/concepts#document-source) such as [CSV](/docs/drivers/csv)
or [XLSX](/docs/drivers/xlsx). For those document
sources, `sq` loads the source data into a [scratch database](/docs/concepts#scratch-db),
and executes the query against that database.

## Fundamentals

Let's take a look at a query.

```shell
$ sq '@sakila_pg | .actor | .first_name, .last_name | .[0:3]'
first_name  last_name
PENELOPE    GUINESS
NICK        WAHLBERG
ED          CHASE
```

You can probably guess what's going on above. This query has 4 _segments_:

| Handle       | Table Selector(s) | Column Expression(s)      | Row Range |
|--------------|-------------------|---------------------------|-----------|
| `@sakila_pg` | `.actor`          | `.first_name, .last_name` | `.[0:3]`  |

Behind the scenes, this SLQ query is translated to a SQL query, which is executed
against the `@sakila_pg` source (which in this example is a [Postgres](/docs/drivers/postgres)
database). The SQL generated query will look something like:

```sql
SELECT "first_name", "last_name" FROM "actor" LIMIT 3 OFFSET 0
```

## Shorthand

For a single-table query, you can concatenate the handle and table name.
In this example, we list all the rows of the `actor` table.

```shell
# Longhand
$ sq '@sakila_pg | .actor'

# Shorthand
$ sq '@sakila_pg.actor'
```

If the query only has a single segment and doesn't contain any shell delimiters
or control chars, you can omit the quotes:

```shell
$ sq @sakila_pg.actor
```

If the query is against the [active source](/docs/cmd/src), then you don't even
need to specify the handle.

```shell
$ sq .actor
```

## Column Aliases

You can use the column alias feature to change the name of one or more columns.
For example:

```shell
$ sq '.actor | .first_name:given_name, .last_name:family_name'
given_name   family_name
PENELOPE     GUINESS
NICK         WAHLBERG
```

Behind the scenes, `sq` uses the SQL `column AS alias` construct. The query
above would be rendered into SQL like this:

```sql
SELECT "first_name" AS "given_name", "last_name" AS "family_name" FROM "actor"
```

This works for any type of column expression, including functions.

```sql
$ sq '.actor | count(*):quantity'
quantity
200
```


[//]: # (## Joins)

[//]: # ()
[//]: # (Use the `join` construct to join two tables, in a single data source, or across)

[//]: # (data sources.)

[//]: # ()
[//]: # (## Single-source join)

[//]: # ()
[//]: # (This example joins two tables in the same source.)

[//]: # ()
[//]: # (```shell)

[//]: # ()
[//]: # (```)

