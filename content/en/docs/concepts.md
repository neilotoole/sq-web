---
title: "Concepts"
description: "Concepts & Terminology"
lead: ""
draft: false
images: []
weight: 1030
toc: true
url: /docs/concepts
aliases:
- /docs/terminology

---
## sq

`sq` is the command-line utility itself. It is free/libre open-source software, available
under the [MIT License](https://github.com/neilotoole/sq/blob/master/LICENSE). The code is
available on [GitHub](https://github.com/neilotoole/sq). `sq` was created
by [Neil O'Toole](https://github.com/neilotoole).

## SLQ

`SLQ` is the formal name of `sq`'s query language, similar to jq's syntax.
The [Antlr](https://www.antlr.org) grammar
is available on [GitHub](https://github.com/neilotoole/sq/tree/master/grammar).

## Source

A _source_ is a data source such as a database instance ([SQL source](#sql-source)),
or an Excel or CSV file ([document source](#document-source)).
A source has a [driver type](#driver-type), [location](#location) and [handle](#handle).

Learn more in the [sources](/docs/source) section.

### Driver type

This is the [driver](#driver) type used to connect to the source,
e.g. `postgres`, `sqlserver`, `csv`, etc. You can specify the type explicitly
when invoking [`sq add`](/docs/cmd/add), but usually `sq` can [detect](/docs/detect/#driver-type)
the driver automatically.

### Location

The source _location_ is the URI or file path of the source, such
as `postgres://sakila:****@localhost/sakila`
or `/Users/neilotoole/sq/xl_demo.xlsx`. You specify the source location when
invoking [`sq add`](/docs/cmd/add).

### Handle

The _handle_ is how `sq` refers to a data source, such as `@sakila` or `@customer_csv`.
The handle must begin with `@`. You specify the handle when adding a source with [`sq add`](/docs/cmd/add).
The handle can also be used to specify a source [group](/docs/source#groups), e.g. `@prod/sales`, `@dev/sales`.

## Active source

The _active source_ is the _source_ upon which `sq` acts if no other source is specified.

By default, `sq` requires that the first element of a query is the source handle:

```shell
$ sq '@sakila | .actor | .first_name, last_name'

```

But if an active source is set, you can omit the handle:

```shell
$ sq '.actor | .first_name, .last_name'
```

You can use [`sq src`](/docs/cmd/src) to get or set the active source.

## SQL source

A _SQL source_ is a source backed by a "real" DB, such as Postgres. Contrast
with [document source](#document-source).

## Document source

A _document source_ is a source backed by a document or file such as [CSV](/docs/drivers/csv) or
[XLSX](/docs/drivers/xlsx). Some functionality
is not available for document sources. For example, `sq` doesn't provide a mechanism to insert query
results into a CSV file. Contrast with [SQL source](#sql-source).

## Group

The _group_ mechanism organizes sources into groups, based on path-like names.
Given handles `@prod/sales`, `@dev/sales` and `@dev/test`, we have three
sources, but two groups, `prod` and `dev`. See the [groups](/docs/source#groups) docs.

## Active group

Like [active source](#active-source), there is an active [group](/docs/source#groups). Use
the [`sq group`](/docs/cmd/group) to get or set the active group.

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

![sq inspect source text](/images/sq_inspect_source_text.png)

`sq inspect` comes into its own when used with the `--json` flag, which outputs voluminous info
on the data source. It is a frequent practice to combine `sq inspect`
with [jq ](https://jqlang.github.io/jq/).
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
