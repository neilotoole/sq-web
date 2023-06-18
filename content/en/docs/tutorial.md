---
title: Tutorial
description: sq tutorial
lead: ''
draft: false
images: []
weight: 1070
toc: true
---

This tutorial walks through `sq`'s features.

If you haven't installed `sq`, see [here](/docs/install). If you've already
installed `sq`, check that you're on a
recent version like so:

```shell
$ sq version
sq v0.38.0
```

If your version is older than that, please [upgrade](/docs/install).
Then start with `sq help`.

## Basics

Let's set out with an example, in this case an Excel file.

```shell
# No data source added to sq yet, so "sq ls" is empty.
$ sq ls

$ wget https://sq.io/testdata/xl_demo.xlsx

$ sq add xl_demo.xlsx --ingest.header --handle @xl_demo
@xl_demo  xlsx  xl_demo.xlsx

$ sq ls
@xl_demo*  xlsx  xl_demo.xlsx

$ sq ls -v
HANDLE     DRIVER  LOCATION
@xl_demo*  xlsx    /Users/neilotoole/sq/xl_demo.xlsx

$ sq inspect @xl_demo
HANDLE    DRIVER  NAME          SIZE   TABLES  LOCATION
@xl_demo  xlsx    xl_demo.xlsx  9.7KB  2       /Users/neilotoole/sq/xl_demo.xlsx

TABLE    ROWS  COL NAMES
person   7     uid, username, email, address_id
address  2     address_id, street, city, state, zip, country
```

Let's step through the above:

- `sq ls`: list the current sources. There are none.
- `wget`: download an Excel file to use for this demo.
- `sq add`: add a source. The _type_ is inferred (or can be specified with `--driver=xlsx`) to be `xlsx`, and we give
  this _source_ the handle `@xl_demo`. This Excel file has a header row, so we also specify `--ingest.header=true` to
  indicate that the actual data begins on row 1, not row 0 (which is the header row).
- `sq ls`: lists the sources again; this time we see our new `@xl_demo` source. The asterisk beside the
  _handle_ (`@xl_demo*`) indicates that this is the _active source_.
- `sq ls -v`: lists the sources yet again, this time verbosely (`-v`).
- `sq inspect`: inspects `@xl_demo`, showing the structure of the source.

## Query

Now that we have added a source to `sq`, we can query it.

```shell
$ sq @xl_demo.person
uid  username    email                  address_id
1    neilotoole  neilotoole@apache.org  1
2    ksoze       kaiser@soze.org        2
3    kubla       kubla@khan.mn          NULL
4    tesla       nikolia@tesla.rs       1
5    augustus    augustus@caesar.org    2
6    julius      julius@caesar.org      NULL
7    plato       plato@athens.gr        1
```

That listed the contents of the `person` table (which for Excel, a _table_ means a _sheet_). Being that `@xl_demo` is
the _active source_, `sq @xl_demo.person` can also be accomplished by `sq .person`.

The same query can be executed in the `scratch` db's native SQL dialect like this (SQLite by default):

```shell
$ sq sql "SELECT * FROM person"
uid  username    email                  address_id
1    neilotoole  neilotoole@apache.org  1
2    ksoze       kaiser@soze.org        2
3    kubla       kubla@khan.mn          NULL
4    tesla       nikolia@tesla.rs       1
5    augustus    augustus@caesar.org    2
6    julius      julius@caesar.org      NULL
7    plato       plato@athens.gr        1
```

Here's some examples of using the _SLQ_ query language:

```shell
$  sq '.person | where(.uid == 3)'
uid  username  email          address_id
3    kubla     kubla@khan.mn  NULL
```

It should be obvious that the above query effectively does a `WHERE uid = 3`.

```shell
$ sq '.person | .[2:5] | .uid, .email, .address_id'
uid  email                address_id
3    kubla@khan.mn        NULL
4    nikolia@tesla.rs     1
5    augustus@caesar.org  2
```

Above we select (zero-indexed) rows 2-5, and output columns `uid` and `email`. The same could be accomplished by:

```shell
$ sq sql 'SELECT uid, email, address_id FROM person LIMIT 3 OFFSET 2'
uid  email                address_id
3    kubla@khan.mn        NULL
4    nikolia@tesla.rs     1
5    augustus@caesar.org  2
```

We could also output in JSON using `sq --json '.person | .uid, .email, .address_id | .[2:5]'`:

```json
[
  {
    "uid": 3,
    "email": "kubla@khan.mn",
    "address_id": null
  },
  {
    "uid": 4,
    "email": "nikolia@tesla.rs",
    "address_id": 1
  },
  {
    "uid": 5,
    "email": "augustus@caesar.org",
    "address_id": 2
  }
]
```

> In addition to standard JSON, you can output in _JSON Lines_ format with the `--jsonl` flag:
>
> ```json
> {"uid": 3, "email": "kubla@khan.mn", "address_id": null}
> {"uid": 4, "email": "nikolia@tesla.rs", "address_id": 1}
> {"uid": 5, "email": "augustus@caesar.org", "address_id": 2}
> ```
>
> Or in _JSON Array_ format with `--jsona`:
>
> ```json
> [3, "kubla@khan.mn", null]
> [4, "nikolia@tesla.rs", 1]
> [5, "augustus@caesar.org", 2]
> ```
>
> Or output in other formats: XML, HTML, Markdown, CSV, Excel, etc..

## Join

Let's look at the other "table" in the Excel spreadsheet:

```shell
$ sq .address
address_id  street            city        state  zip    country
1           1600 Penn         Washington  DC     12345  US
2           999 Coleridge St  Ulan Bator  UB     888    MN
```

We can join across the tables (sheets) of `@xl_demo`:

```shell
$ sq '.person, .address | join(.address_id) | .email, .city'
email                  city
neilotoole@apache.org  Washington
kaiser@soze.org        Ulan Bator
nikolia@tesla.rs       Washington
augustus@caesar.org    Ulan Bator
plato@athens.gr        Washington
```

## Stdin

Let's grab another data source, this time in CSV. We'll download the file.

```shell
$ wget https://sq.io/testdata/person.csv
```

Now let's take a look at it:

```shell
$ cat person.csv | sq inspect
HANDLE  DRIVER  NAME    SIZE    TABLES  LOCATION
@stdin  csv     @stdin  199.0B  1       @stdin

TABLE  ROWS  SIZE  NUM COLS  COL NAMES   COL TYPES
data   7     -     4         A, B, C, D  INTEGER, TEXT, TEXT, INTEGER
```

> Note that because CSV is  "_monotable_" (only has one table of data), its data is represented as a single table
> named `data`. Also note that because this particular CSV file doesn't have a header row, its columns are given
> names `A`, `B`, `C`, etc., following what Excel would do.

We can pipe that CSV file to `sq` and performs the usual actions on it:

```shell
$ cat person.csv | sq '.data | .[2:5]'
A  B         C                    D
3  kubla     kubla@khan.mn        NULL
4  tesla     nikola@tesla.rs      1
5  augustus  augustus@caesar.org  2
```

We could continue to `cat` the CSV file to `sq`, but being that we'll use it later in this tutorial, we'll add it as a
source:

```shell
$ sq add person.csv -h @csv_demo
@csv_demo  csv  person.csv
```

As with the sheets of the Excel file, we can also join across sources:

```shell
$ sq '@csv_demo.data, @xl_demo.address | join(.D == .address_id) | .C, .city'
C                      city
neilotoole@apache.org  Washington
kaiser@soze.org        Ulan Bator
nikola@tesla.rs        Washington
augustus@caesar.org    Ulan Bator
plato@athens.gr        Washington
```

## Active Source

Now that we've added multiple sources, let's see what `sq ls` has to say:

```shell
$ sq ls
@xl_demo*    xlsx  xl_demo.xlsx
@csv_demo    csv   person.csv
```

Note that `@xl_demo` is the active source (it has an asterisk beside it). We can do this with `@csv_demo`:

```shell
$ sq '@csv_demo.data | .[0:1]'
A  B           C                      D
1  neilotoole  neilotoole@apache.org  1
```

But not this:

```shell
$ sq '.data | .[0:1]'
sq: SQL query against @xl_demo failed: SELECT * FROM "data"  LIMIT 1 OFFSET 0: no such table: data
```

Because the active source is still `@xl_demo`. To see the active source:

```shell
$ sq src
@xl_demo  xlsx  xl_demo.xlsx
```

Let's switch the active source to the CSV file:

```shell
$ sq src @csv_demo
@csv_demo  csv  person.csv
```

Now we can use the shorthand form (omit the `@csv_demo` handle) and `sq` will look for table `.data` in the active
source (which is now `@csv_demo`):

```shell
$ sq '.data | .[0:1]'
A  B           C                      D
1  neilotoole  neilotoole@apache.org  1
```

## Ping

A useful feature is to ping the sources to verify that they're accessible:

```shell
# Ping sources in the root group, i.e. all sources.
$ sq ping /
@csv_demo       1ms  pong
@xl_demo        3ms  pong
```

Or we could ping just one or two sources:

```shell
$ sq ping @xl_demo @csv_demo
@csv_demo       1ms  pong
@xl_demo        3ms  pong
```

## SQL Sources

Having read this far, you can be forgiven for thinking that `sq` only deals with document-type formats such as Excel or
CSV, but that is not the case. Let's add some SQL databases.

First we'll do postgres; we'll start a pre-built [Sakila](https://dev.mysql.com/doc/sakila/en/sakila-introduction.html)
database via docker on port (note that it will take a moment for the Postgres container to start up):

```shell
$ docker run -p 5432:5432 sakiladb/postgres:latest
```

Let's add that Postgres database as a source:

```shell
$ sq add "postgres://sakila:p_ssW0rd@localhost/sakila?sslmode=disable"
@sakila_pg  postgres  sakila@localhost/sakila
```

> If you don't want to type the password on the command line, you could instead use an environment variable:
>
> ```shell
> $ export DEMO_PW=p_ssW0rd
> $ sq add "postgres://sakila:$DEMO_PW@localhost/sakila?sslmode=disable"
> @sakila_pg  postgres  sakila@localhost/sakila
> ```

The new source should show up in `sq ls`:

```shell
$ sq ls
@xl_demo     xlsx      xl_demo.xlsx
@csv_demo    csv       person.csv
@sakila_pg*  postgres  sakila@localhost/sakila
```

Ping the new source just for fun:

```shell
$ sq ping @sakila_pg
@sakila_pg       9ms  pong
```

We'll inspect a single table (just to keep the output small):

```shell
$ sq inspect @sakila_pg.actor
TABLE  ROWS  SIZE    NUM COLS  COL NAMES                                     COL TYPES
actor  200   72.0KB  4         actor_id, first_name, last_name, last_update  integer, character varying, character varying, timestamp without time zone
```

And take a little taste of that data:

```shell
$ sq '@sakila_pg.actor | .[0:2]'
actor_id  first_name  last_name  last_update
1         PENELOPE    GUINESS    2006-02-15 04:34:33 +0000 UTC
2         NICK        WAHLBERG   2006-02-15 04:34:33 +0000 UTC
```

Now we'll add and start a MySQL instance of _Sakila_:

```shell
$ docker run -p 3306:3306 sakiladb/mysql:latest
$ sq add "mysql://sakila:p_ssW0rd@localhost/sakila"
@sakila_my  mysql  sakila@localhost/sakila
```

And get some data from `@sakila_my`:

````shell
$ sq '@sakila_my.actor | .[0:2]'
actor_id  first_name  last_name  last_update
1         PENELOPE    GUINESS    2006-02-15 04:34:33 +0000 UTC
2         NICK        WAHLBERG   2006-02-15 04:34:33 +0000 UTC
```shell

> Note that as before `sq` can join across sources:
>
> ```

> sq '@sakila_pg.city, @sakila_my.country | join(.country_id) | .city, .country | .[0:3]'
> city country
> A Corua (La Corua)  Spain
> Abha Saudi Arabia
> Abu Dhabi United Arab Emirates
> ```

## Insert & Modify

In addition to JSON, CSV, etc., `sq` can write query results to database tables.

We'll use the `film_category` table as an example: the table is in both `@sakila_pg` and `@sakila_my`. We're going to
truncate the table in `@sakila_my` and then repopulate via a query against `@sakila_pg`.

```shell
$ sq '@sakila_pg.film_category | count()'
count
1000

$ sq '@sakila_my.film_category | count()'
COUNT(*)
1000
````

Make a copy of the table as a backup.

```shell
$ sq tbl copy .film_category .film_category_bak
Copied table: @sakila_my.film_category --> @sakila_my.film_category_bak (1000 rows copied)
```

> Note that the `sq tbl copy` makes use each database's own table copy functionality. Thus `sq tbl copy` can't be used
> to directly copy a table from one database to another. But `sq` provides a means of doing this, keep reading.

Truncate the `@sakila_my.film_category` table:

```shell
$ sq tbl truncate @sakila_my.film_category
Truncated 1000 rows from @sakila_my.film_category

$ sq '@sakila_my.film_category | count()'
COUNT(*)
0
```

The `@sakila_my.film_category` table is now empty. But we can repopulate it via a query against `@sakila_pg`. For this
example, we'll just do `500` rows.

```shell
$ sq '@sakila_pg.film_category | .[0:500]' --insert @sakila_my.film_category
Inserted 500 rows into @sakila_my.film_category

$ sq '@sakila_my.film_category | count()'
COUNT(*)
500
```

We can now use the `sq tbl` commands to restore the previous state.

```shell
# Set @sakila_my as the active source just for brevity.
$ sq src @sakila_my

$ sq tbl drop .film_category
Dropped table @sakila_my.film_category

# Restore the film_category table from the backup table we made earlier
$ sq tbl copy .film_category_bak .film_category
Copied table: @sakila_my.film_category_bak --> @sakila_my.film_category (1000 rows copied)

# Verify that the table is restored
$ sq '.film_category | count()'
COUNT(*)
1000

# Get rid of the backup table
$ sq tbl drop .film_category_bak
Dropped table @sakila_my.film_category_bak

```

## jq

Note that `sq` plays nicely with jq. For example, list the names of the columns in table `@sakila_pg.actor`:

```shell
$ sq inspect --json @sakila_pg.actor | jq -r '.columns[] | .name'
actor_id
first_name
last_name
last_update
```
