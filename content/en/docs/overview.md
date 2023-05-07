---
title: Overview
description: Introduction to sq
lead: ''
draft: false
images: []
weight: 1010
toc: true
---

`sq` is the missing tool for wrangling data. A swiss-army knife for data.

`sq` provides a `jq`-style syntax to query, join, migrate, and export data from a variety of data sources,
such as Postgres, SQLite, SQL Server, MySQL, Excel or CSV, with the ability to fall back
to actual SQL for trickier work. In essence, `sq` treats every data source as if it were a SQL database.
`sq` also provides several handy commands such as `inspect`, `ping`, or `tbl copy`.

## Key Concepts

- `sq` is the command-line utility itself.
- A *source* is a specific data source such as a database instance, or Excel or CSV file etc. Each source
  has a:
  - `driver`: such as [`postgres`](/docs/drivers/postgres), [`sqlserver`](/docs/drivers/sqlserver),
    [`csv`](/docs/drivers/csv), or [`xlsx`](/docs/drivers/xlsx).
  - `location`: URI or filepath of the source, such as `postgres://sakila:****@localhost/sakila` or `/Users/neilotoole/sq/xl_demo.xlsx`.
  - `handle`: this is how `sq` refers to that particular _source_, e.g. `@sakila_pg`, `@prod/customer` or `@xl_demo`. The handle must begin with `@`.
- [Active Source](/docs/concepts/#active-source) is the default source upon which `sq` acts if no other source is specified.
- [`sq inspect`](/docs/cmd/inspect) returns _metadata_ about your source, such as table names or number of rows.

Read more in [Concepts](/docs/concepts).

## Quick start

1. [Install](/docs/install) `sq`.
1. [Add](/docs/cmd/add/) a data source. We'll use an Excel file.
   ```shell
   $ sq add --handle @demo https://sq.io/testdata/xl_demo.xlsx
   @demo  xlsx  xl_demo.xlsx
   ```
1. Inspect the source:
   ```shell
   $ sq inspect @demo
   HANDLE  DRIVER  NAME          SIZE   TABLES  LOCATION
   @demo   xlsx    xl_demo.xlsx  9.7KB  2       https://sq.io/testdata/xl_demo.xlsx

   TABLE    ROWS  COL NAMES
   person   8     A, B, C, D
   address  3     A, B, C, D, E, F
   ```
1. Run a query, getting the first three rows of the `person` table.:
   ```shell
   $ sq '@demo.person | .[0:3]'
   A    B           C                      D
   uid  username    email                  address_id
   1    neilotoole  neilotoole@apache.org  1
   2    ksoze       kaiser@soze.org        2
   ```
1. Run the query again, but output in a different format:
   ```shell
   $ sq '@demo.person | .[0:3]' --jsonl
   {"A": "uid", "B": "username", "C": "email", "D": "address_id"}
   {"A": "1", "B": "neilotoole", "C": "neilotoole@apache.org", "D": "1"}
   {"A": "2", "B": "ksoze", "C": "kaiser@soze.org", "D": "2"}
   ```

Next, read the [tutorial](/docs/tutorial).

## Commands

Use `sq help` to list the available commands, or consult the [reference](/docs/cmd/)
for each command.

```text
Available Commands:
  add         Add data source
  src         Get or set active data source
  group       Get or set active group
  ls          List sources and groups
  mv          Move/rename sources and groups
  rm          Remove data source or group
  inspect     Inspect data source schema and stats
  ping        Ping data sources
  sql         Execute DB-native SQL query or statement
  driver      List or manage drivers
  tbl         Useful table actions (copy, truncate, drop)
  completion  Generate shell completion script
  version     Print sq version
  help        Show sq help

Flags:
  -o, --output string   Write output to <file> instead of stdout
  -j, --json            Output JSON
  -A, --jsona           Output LF-delimited JSON arrays
  -l, --jsonl           Output LF-delimited JSON objects
  -t, --table           Output text table
  -X, --xml             Output XML
  -x, --xlsx            Output Excel XLSX
  -c, --csv             Output CSV
  -T, --tsv             Output TSV
  -r, --raw             Output each record field in raw format without any encoding or delimiter
      --html            Output HTML table
      --md              Output Markdown
  -h, --header          Print header row in output (default true)
      --pretty          Pretty-print output (default true)
      --insert string   Insert query results into @HANDLE.TABLE. If not existing, TABLE will be created.
      --src string      Override the active source for this query
      --driver string   Explicitly specify the data source driver to use when piping input
      --opts string     Driver-dependent data source options when piping input
      --version         Print sq version
      --help            Show sq help
  -M, --monochrome      Don't colorize output
  -v, --verbose         Print verbose output, if applicable
```

## Issues

File any bug reports or other issues [here](https://github.com/neilotoole/sq/issues).
When filing a bug report, submit a [log file](/docs/config#logging).

## Config

`sq` is highly configurable. See the [config](/docs/config) section.

### Logging

By default, `sq` logging is disabled. See the [logging](/docs/config#logging) section
to learn how to enable logging.
