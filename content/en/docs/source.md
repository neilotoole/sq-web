---
title: Sources
description: Sources
lead: ''
draft: false
images: []
weight: 1036
toc: true
url: /docs/source
---
A _source_ is an individual data source, such as a database connection, or
a CSV or Excel document.

## Overview

A source has three main elements:

- _**driver:**_ a [driver](/docs/drivers) type such as `postgres`, or `csv`.
- _**handle:**_ such as `@sakila_pg`. A handle always starts with `@`. The handle is used to refer
  to the data source. A handle can also specify a [group](#groups), e.g. `@prod/sakila`.
- _**location:**_ such as `postgres://user:p_ssW0rd@localhost/sakila`. For
  a document source, _location_ may just be a file path, e.g. `/Users/neilotoole/sakila.csv`.

{{< alert icon="👉" >}}
When `sq` prints a location containing security credentials (such as the password in the
postgres string above), the credentials are redacted. Thus, that location string
would be printed as `postgres://user:xxxxx@@localhost/sakila`.
{{< /alert >}}

`sq` provides a set of commands to [add](#add), [list](#list-sources), [rename](#move)
and [remove](#remove) sources.

## Add

To add a source, use `sq add`. The command packs in a lot of functionality:
see the [docs](/docs/cmd/add) for detail.

```shell
# Add a postgres database
$ sq add postgres://sakila:p_ssW0rd@localhost/sakila
@sakila_pg  postgres  sakila@localhost/sakila

# Add a CSV source, specifying the handle.
$ sq add ./actor.csv --handle @actor
```

### Location completion

It can be difficult to remember the format of database URLs (i.e. the source **location**).
To make life easier, `sq` provides shell completion for the `sq add LOCATION` field. To
use it, just press `TAB` after `$ sq add`.

For location completion to work, do not enclose the location in single quotes. However,
this does mean that the inputted location string must escape special shell characters
such as `?` and `&`.

```shell
# Location completion not available, because location is in quotes.
$ sq add 'postgres://sakila@192.168.50.132/sakila?sslmode=disable'

# Location completion available: note the escaped ?.
$ sq add postgres://sakila@192.168.50.132/sakila\?sslmode=disable
```

The location completion mechanism suggests usernames, hostnames (from history),
database names, and even values for query params (e.g. `?sslmode=disable`) for
each supported database. It never suggests passwords.

{{< asciicast src="/casts/src-add-location-completion-pg.cast" poster="npt:0:8" idleTimeLimit=0.5 rows=6 speed=1.5 >}}


## List sources

Use [`sq ls`](/docs/cmd/ls) to list sources.

```shell
$ sq ls
@dev/customer   csv  customer.csv
@dev/sales      csv  sales.csv
@prod/customer  csv  customer.csv
@prod/sales     csv  sales.csv
```

In practice, colorization makes things a little easier to parse.

![sq ls](/images/sq_ls.png)

Note that the `@dev/sales` source is highlighted. This means that it's
the [active source](#active-source) (you can get the active source
at any time via `sq src`).

Pass the `-v` (`--verbose`) flag to see more detail:

```shell
$ sq ls -v
HANDLE          ACTIVE  DRIVER  LOCATION                                                                   OPTIONS
@dev/customer           csv     /Users/neilotoole/sakila-csv/customer.csv
@dev/sales      active  csv     /Users/neilotoole/sakila-csv/sales.csv
@prod/customer          csv     /Users/neilotoole/sakila-csv/customer.csv
@prod/sales             csv     /Users/neilotoole/sakila-csv/sales.csv
```

`sq ls` operates on the active group. By default, this is the `/` root group.
So, when the default group is `/`, then `sq ls` is equivalent to `sq ls /`.
But just like the UNIX `ls` command, you can supply an argument to `sq ls` to
list the sources in that group.

```shell
# List sources in the "prod" group.
$ sq ls prod
@prod/customer  csv  customer.csv
@prod/sales     csv  sales.csv
```

## List groups

Use `sq ls -g` (`--group`) to list [groups](#groups) instead of sources.

```shell
$ sq ls -g
/
dev
prod
```

See more detail by adding `-v`:

![sq ls -gv](/images/sq_ls_gv_short.png)

Like the plain `sq ls` command, you can pass an argument to `ls -g` to
see just the subgroups of the argument.

```shell
$ sq ls -gv prod
GROUP  SOURCES  TOTAL  SUBGROUPS  TOTAL  ACTIVE
prod   2        2
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
Various other commands (such as [`sq ls`](/docs/cmd/ls) and [`sq ping`](/docs/cmd/ping)) also make
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
If no active source is set (like when you first start using `sq`), and
you `sq add` a source, that source becomes the active source.

When you `sq rm` the active source, there will no longer be an active source.
{{< /alert >}}

Like the active source, there is an [active group](#groups). Use
the equivalent [`sq group`](/docs/cmd/group) command to get or set the active group.

## Remove

Use [`sq rm`](/docs/cmd/rm) to remove a source (or [group](#groups) of sources).

{{< alert icon="👉" >}}
Rest assured, `sq rm` only removes the reference to the source
from `sq`'s configuration.
It doesn't do anything destructive to the source itself.
{{< /alert >}}

```shell
# Remove a single source.
$ sq rm @sakila_pg

# Remove multiple sources at once.
$ sq rm @sakila_pg @sakila_sqlite

# Remove all sources in the "dev" group.
$ sq rm dev

# Remove a mix of sources and groups.
$ sq rm @prod/customer staging
```

## Move

Use `sq mv` to move (rename) sources and groups. `sq mv` works analogously
to the UNIX `mv` command, where source handles are equivalent to files,
and [groups](#groups) are equivalent to directories.

```shell
# Rename a source
$ sq mv @dev/sales @dev/europe/sales
@dev/europe/sales  csv  sales.csv

# Move a source into a group (the group need not exist beforehand).
$ sq mv @dev/customer dev/europe
@dev/europe/customer  csv  customer.csv

# Rename a group (and by extension, rename all of the group's sources).
$ sq mv dev/europe dev/europa
dev/europa
```

## Ping

Use [`sq ping`](/docs/cmd/ping) to check the connection health of your sources.
If invoked without argumetns, `sq ping` pings the active source. Otherwise, supply
a list of sources or groups to ping.

```shell
# Ping the active source.
$ sq ping

# Ping all sources.
$ sq ping /

# Ping @sakila_my, and sources in the "prod" and "staging" groups
$ sq ping @sakila_my prod staging
```

![sq ping](/images/sq_ping_sakila.png)

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

{{< alert icon="👉" >}}
Groups effectively form a hierarchy, like a filesystem, where source handles
are equivalent to files, and groups are equivalent to directories.
{{< /alert >}}

When you have lots of sources and groups, use `sq ls -gv` (`--group --verbose`)
to see more detail on the hierarchical structure.

```shell
$ sq ls -gv
GROUP  SOURCES  TOTAL  SUBGROUPS  TOTAL  ACTIVE
/               4      2          2
dev    2        2                        active
prod   2        2
```

Here's a real-world example:

![sq ls -gv](/images/sq_ls_gv.png)

If you want to get really crazy, try the JSON output (`sq ls -gj`).


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






