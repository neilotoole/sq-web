---
title: "Terminology"
description: "Terminology"
lead: ""
draft: true
images: []
weight: 98
toc: true
---
- `sq` is the command-line utility itself.
- `SLQ` is the formal name of `sq`'s language, similar to `jq` syntax.
- `source` is a specific data source such as a database instance, or Excel or CSV file etc.. A `source` has a:
  - `type`: such as `postgres`, `sqlserver`, `csv`, or `xlsx`; effectively `type` means the _source driver type_.
  - `location`: the location of the _source_, such as `postgres://sakila:****@localhost/sakila` or `/Users/neilotoole/sq/xl_demo.xlsx`.
  - `handle`: this is how `sq` refers to that particular _source_, e.g. `@sakila_pg` or `@xl_demo`. A `handle` must begin with `@`.
- `active source` is the _source_ upon which `sq` acts if no other source is specified.
- `driver` is a software component implemented by `sq` for each data source type. For example, `postgres`, or `csv`.
- `scratchdb` means the _scratch_ or temporary database that `sq` uses for under-the-hood activity such as converting a non-SQL source like XLSX to relational format.
- `joindb` is similar to `scratchdb`, but is used for cross-source joins.
- `monotable` means that the _source_ type is really only a single table, such as CSV: that single table is named `data`.


