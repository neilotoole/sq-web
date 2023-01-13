---
title : "sq"
description: "sq is for wrangling data"
lead: "wrangle data"
draft: false
images: []
---

{{< asciicast src="/casts/home-quick.cast"  poster="npt:0:25" rows=10 autoPlay=true speed=3 idleTimeLimit=3 >}}

`sq` is a free/libre [open-source](https://github.com/neilotoole/sq) data wrangling swiss-army knife
to inspect, query, join, import, and export data. You could think of `sq`
as [jq](https://stedolan.github.io/jq/) for databases and documents, facilitating one-liners
like:

```shell
sq '@postgres_db | .actor | .first_name, .last_name | .[0:5]'
```



## Installation

{{< tabs name="sq-install" >}}
{{{< tab name="mac" codelang="shell" >}}brew install neilotoole/sq/sq{{< /tab >}}
{{< tab name="linux" codelang="shell" >}}/bin/sh -c "$(curl -fsSL https://sq.io/install.sh)"{{< /tab >}}}
{{< tab name="win" codelang="shell">}}scoop bucket add sq https://github.com/neilotoole/sq
scoop install sq{{< /tab >}}}
{{% tab name="more" %}}Install options for `apt`, `yum`, `apk`, `pacman`, `yay` over [here](/docs/install).{{% /tab %}}}
{{< /tabs >}}


For help, `sq help` is your starting point. And then see the [docs](/docs).

### Let's get this out of the way

`sq` is pronounced like _seek_. Its query language, `SLQ`, is pronounced like _sleek_.


## Feature Highlights

Some feature highlights are shown below. For more, see the [docs](/docs),
including the [tutorial](/docs/tutorial) and [cookbook](/docs/cookbook).

### Import Excel worksheet into Postgres table

Insert the contents of an Excel XLSX worksheet (from a sheet named `actor`) into
a new Postgres table named `xl_actor`. Note that the import mechanism
is reasonably sophisticated in that it tries to preserve data types.

{{< asciicast src="/casts/excel-to-postgres.cast" poster="npt:0:5" rows=5 >}}


### View metadata for a database

The `--json` flag to `sq inspect` outputs schema and other metadata in JSON.
Typically the output is piped to `jq` to select the interesting elements.

{{< asciicast src="/casts/inspect-sakila-mysql-json.cast" poster="npt:0:9" rows=10 >}}

### Get names of all columns in a MySQL table

{{< asciicast src="/casts/table-column-names-mysql.cast" poster="npt:0:11" rows=8 >}}

Even easier, just get the metadata for the table you want:

```shell
sq inspect @sakila_my.actor -j | jq -r '.columns[] | .name'
```

### Execute SQL query against SQL Server, insert results to SQLite

This snippet adds a (pre-existing) SQL Server source, and creates a
new SQLite source. Then, a raw native SQL query is executed against
SQL Server, and the results are inserted into SQLite.

{{< asciicast src="/casts/sql-query-then-insert.cast" poster="npt:0:55" rows=6 >}}

### Export all database tables to CSV

Get the (JSON) metadata for the active source; pipe that JSON to `jq` and
extract the table names; pipe the table names
to `xargs`, invoking `sq` once for each table, outputting a CSV file per table.

{{< asciicast src="/casts/export-all-tables-to-csv.cast" poster="npt:0:22" idleTimeLimit=0.5 rows=6 speed=2.5 >}}

