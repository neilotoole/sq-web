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

## Source

A source has three main elements:

- `driver`: a [driver](/docs/drivers) type such as `postgres`, or `csv`.
- `handle`: such as `@sakila_pg`. A handle always starts with `@`. The handle is used to refer
  to the data source. A handle can also specify a [group](#groups), e.g. `@prod/sakila`.
- `location`: such as `postgres://user:p_ssW0rd@@localhost/sakila`. For
  a document source, _location_ may just be a file path, e.g. `/Users/neilotoole/sakila.csv`.

{{< alert icon="👉" >}}
When `sq` prints a location containing security credentials (such as the password in the
postgres string above), the credentials are redacted. Thus, the location string above
would be printed as `postgres://user:xxxxx@@localhost/sakila`.
{{< /alert >}}

`sq` provides a set of commands to add, list, rename and remove sources.

## Add

To add a source, use `sq add` (see the [`sq add` docs](/docs/cmd/add) for more).

```shell
# Add a postgres database
$ sq add postgres://sakila:p_ssW0rd@localhost/sakila
@sakila_pg  postgres  sakila@localhost/sakila

# Add a CSV source, specifying the handle.
$ sq add ./actor.csv -h @actors
```

## List

Use [`sq ls`](/docs/cmd/ls) to list sources.

```shell
$ sq ls
@sakila_sl3*   sqlite3    sakila.db
@sakila_pg9    postgres   sakila@192.168.50.137/sakila
@sakila_pg10   postgres   sakila@192.168.50.140/sakila
```

FIXME: Note the `*` beside `@sakila_sl3`: this means that it's
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

{{< alert icon="👉" >}}
Various other commands (such as [`sq ping`](#ping)) also make
use of the active source.
{{< /alert >}}

Use [`sq src`](/docs/cmd/src) to get or set the active source.

```shell
# Get active source
$ sq src
@sakila_sl3  sqlite3  sakila.db

# Set active source
$ sq src @sakila_pg12
@sakila_pg12  postgres  sakila@192.168.50.132/sakila
```

{{< alert icon="👉" >}}
If there is no active source set (like when you first start using `sq`), and
you `sq add` a source, that source becomes the active source.

When you `sq rm` the active source, there will no longer be an active source.
{{< /alert >}}

## Remove

Use [`sq rm`](/docs/cmd/rm) to remove a source (or [group](#groups) of sources).

```shell
# Remove a single source.
$ sq rm @sakila_pg

# Remove multiple sources at once.
$ sq rm @sakila_pg @sakila_sqlite

# Remove all sources in the "dev" group.
$ sq rm dev
```

## Move

TBD


## Ping

Use [`sq ping`](/docs/cmd/ping) to check the connection status of your sources.

```shell
$ sq ping --all
@sakila_my                           42ms  pong
@sakila_pg9                          64ms  pong
@sakila_pg12                         65ms  pong
@pg_sakila_local                     12ms  fail  failed to connect to `host=localhost user=sakila database=sakila`: dial error (dial tcp 127.0.0.1:5432: connect: connection refused)
@sakila2_xlsx                       560ms  fail  open /Users/neilotoole/sakila2.xlsx: no such file or directory
```

## Groups

If you find yourself dealing large numbers of sources, `sq` provides a
simple mechanism to structure groups of sources. A typical handle looks like `@sales`.
But if you use a path structure in the handle like `@prod/sales`,
`sq` interprets that `prod` path as a _group_.

For example, let's say you had two databases, `customer` and `sales`, and two
environments, `dev` and `prod`. You might naively add sources `@dev_customer`,
`@dev_sales`, `@prod_customer`, and `@prod_sales`.

```shell
# This example is using a CSV data source, but it could be postgres, mysql, etc.
$ sq ls
@dev_customer   csv  customer.csv
@dev_sales      csv  sales.csv
@prod_customer  csv  customer.csv
@prod_sales     csv  sales.csv
```
Now, if you have dozens (or hundreds) of sources, interacting with them
becomes burdensome. Enter the _groups_ mechanism. Let's add these sources instead:
`@dev/customer`, `@dev/sales`, `@prod/customer`, `@prod/sales`.

```shell
$ sq ls
@dev/customer   csv  customer.csv
@dev/sales      csv  sales.csv
@prod/customer  csv  customer.csv
@prod/sales     csv  sales.csv
```

So, the `_` char has been replaced with `/`... what's the big difference you ask?

`sq` interprets `/`-separated path values in the handle as groups. By default,
you start out in the root group, represented by `/`. Use `sq group` to see
the active group:

```shell
$ sq group
/
```

Now, let's set the active group to `dev`, and note the different behavior of `sq ls`:

```shell
# Set the active group to "dev".
$ sq group dev
dev

# Now "sq ls" will only list the sources under "dev".
$ sq ls
@dev/customer  csv  customer.csv
@dev/sales     csv  sales.csv
```

You can use `sq group /` to reset the active group to the root group. But you can
also list the sources in a group without changing the active group:

```shell
$ sq ls prod
@prod/customer  csv  customer.csv
@prod/sales     csv  sales.csv
```

If you want to list the groups (as opposed to listing sources), use `ls -g`:

```shell
# Equivalent to "sq ls --group"
$ sq ls -g
/
dev
prod
```

As you can see above, there are three groups: `/` (the root group), `dev`, and `prod`.

You're not restricted to one level of grouping. A handle such as `@mom_corp/prod/europe/sales`
is perfectly valid, and the commands work intuitively. For example, to list all the subgroups
of `mom_corp/prod`:

```shell
$ sq ls -g mom_corp/prod
mom_corp/prod/europe
mom_corp/prod/na
mom_corp/prod/africa
```

Groups effectively form a hierarchy, like a filesystem, where sources
are equivalent to files, and groups are equivalent to directories.

When you have lots of sources and groups, use `sq ls -gv` (`--group --verbose`)
to see more detail on the hierarchical structure.

```shell
$ sq ls -gv
GROUP  SOURCES  TOTAL  SUBGROUPS  TOTAL  ACTIVE
/               4      2          2
dev    2        2                        active
prod   2        2
```


{{< alert icon="👉" >}}
You may have noticed by now that groups are _implicit_. A group "exists" when
there exists a source that has the group's path in the handle. Thus, there
is no command to "add a group". However, you can rename ([move](#move))
and [remove](#remove) groups.

```shell
# Rename a group, i.e. rename all the sources in the group.
$ sq mv old/group new/group

# Remove a group, i.e. remove all the sources in the group.
$ sq rm my/group
```

These commands are effectively batch operations on the sources in each group.
{{< /alert >}}






