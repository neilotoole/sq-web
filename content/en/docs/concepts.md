---
title: "Concepts"
description: "Concepts & Terminology"
lead: ""
draft: false
images: []
weight: 1030
toc: true
aliases:

- /docs/terminology

---

## sq

`sq` is the command-line utility itself. It is free/libre open-source software, available
under the [MIT License](https://github.com/neilotoole/sq/blob/master/LICENSE). The code is
available on [GitHub](https://github.com/neilotoole/sq). `sq` was created
by [Neil O'Toole](https://github.com/neilotoole).

## SLQ

`SLQ` is the formal name of `sq`'s query language, similar to `jq`'s syntax.
The [Antlr](https://www.antlr.org) grammar
is available on [GitHub](https://github.com/neilotoole/sq/tree/master/grammar).

## Source

A _source_ is a data source such as a database instance ([SQL source](#sql-source)),
or an Excel or CSV file ([document source](#document-source)).
A source has a [driver type](#driver-type), [location](#location) and [handle](#handle).
Some driver types accept options via [`sq add --opts`](/docs/cmd/add).

### Driver Type

The _type_ is the [driver](#driver) type used to connect to the source,
e.g. `postgres`, `sqlserver`, `csv`, etc. You can specify the type explicitly
when invoking [`sq add`](/docs/cmd/add), but usually `sq` can infer the type
from the [location](#location).

### Location

The source _location_ is the URI or file path of the source, such
as `postgres://sakila:****@localhost/sakila`
or `/Users/neilotoole/sq/xl_demo.xlsx`. You specify the source location when
invoking [`sq add`](/docs/cmd/add).

### Handle

The _handle_ is how `sq` refers to a data source, such as `@sakila` or `@customer_csv`.
A `handle` must begin with `@`. You specify the handle when adding a source with [`sq add`](/docs/cmd/add).

## Active Source

An `active source` is the _source_ upon which `sq` acts if no other source is specified.

By default, `sq` requires that the first element of a query is the source handle:

```shell
$ sq '@sakila | .actor | .first_name, last_name'

```

But if an active source is set, you can omit the handle:

```shell
$ sq '.actor | .first_name, .last_name'
```

You can use [`sq src`](/docs/cmd/src) to get or set the active source.

## SQL Source

A _SQL Source_ is a source backed by a "real" DB, such as Postgres. Contrast
with [document source](#document-source).

## Document Source

A _document source_ is a source backed by a document or file such as [CSV](/docs/drivers/csv) or
[XLSX](/docs/drivers/xlsx). Some functionality
is not available for document sources. For example, `sq` doesn't provide a mechanism to insert query
results into a CSV file. Contrast with [SQL Source](#sql-source).

## Driver

A `driver` is a software component implemented by `sq` for each data source type. For
example, [Postgres](/docs/drivers/postgres) or [CSV](/docs/drivers/csv).

Use [`sq driver ls`](/docs/cmd/driver-ls) to view the available drivers.

## Monotable

If a source is `monotable`, it means that the source type is really only a single table, such
as a [CSV](/docs/drivers/csv) file. `sq` always names that single table `data`. You access that
table
like this: `@actor_csv | .data`.

Note that not all document sources are _monotable_. For example, [XLSX](/docs/drivers/xlsx) sources
have multiple tables, where each worksheet is effectively equivalent to a DB table.

## Metadata

[`sq inspect`](/docs/cmd/inspect) returns metadata about a source. At a minimum, `sq inspect`
is useful for a quick reminder of table and column names:

```shell
$ sq inspect
HANDLE      DRIVER    NAME    FQ NAME        SIZE    TABLES  LOCATION
@sakila_pg  postgres  sakila  sakila.public  14.6MB  28      postgres://sakila:xxxxx@localhost/sakila

TABLE                       ROWS   COL NAMES
actor                       200    actor_id, first_name, last_name, last_update
actor_info                  200    actor_id, first_name, last_name, film_info
address                     603    address_id, address, address2, district, city_id, postal_code, phone, last_update
```

`sq inspect` comes into its own when used with the `--json` flag, which outputs voluminous info
on the data source. It is a frequent practice to combine `sq inspect`
with [jq](https://stedolan.github.io/jq/).
For example, to list the tables of the active source:

```shell
$ sq inspect -j | jq -r '.tables[] | .name'
actor
address
category
[...]
```

See more examples in the [cookbook](/docs/cookbook).

## Scratch DB

_Scratch DB_ refers to the temporary ("_scratch_") database that `sq` uses for under-the-hood
activity
such as converting a [document source](#document-source) like [CSV](/docs/drivers/csv) to relational
format. By default, `sq`
uses an embedded [SQLite](/docs/drivers/sqlite) instance for the Join DB.

## Join DB

_Join DB_ is similar to [Scratch DB](#join-db), but is used for cross-source joins. By default, `sq`
uses an embedded [SQLite](/docs/drivers/sqlite) instance for the Join DB.
