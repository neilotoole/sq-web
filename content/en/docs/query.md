---
title: Query Guide
description: Guide to sq's query language
lead: ''
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
| ------------ | ----------------- | ------------------------- | --------- |
| `@sakila_pg` | `.actor`          | `.first_name, .last_name` | `.[0:3]`  |

Ultimately the SLQ query is translated to a SQL query, which is executed
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

## Filter results

Use a filter expression to filter results.

```shell
$ sq '.actor | .first_name, .last_name | .first_name == "TOM"'
first_name  last_name
TOM         MCKELLEN
TOM         MIRANDA
```

Ultimately a filter is translated into a SQL `WHERE` clause such as:

```sql
SELECT "first_name", "last_name" FROM "actor" WHERE  "first_name" = "TOM"
```

If a column has an [alias](#column-aliases), you can use either the original
name or the alias in the expression.

```shell
$ sq '.actor | .first_name:given_name | .given_name == "TOM"'
```

## Operators

The typical comparison operators are available in expressions:

```shell
$ sq '.actor | .actor_id < 3'
actor_id  first_name  last_name  last_update
1         PENELOPE    GUINESS    2020-06-11T02:50:54Z
2         NICK        WAHLBERG   2020-06-11T02:50:54Z
```

| Operator | Description              |
| -------- | ------------------------ |
| `==`     | Equal to                 |
| `!=`     | Not equal to             |
| `<`      | Less than                |
| `<=`     | Less than or equal to    |
| `>`      | Greater than             |
| `>=`     | Greater than or equal to |

## Row range

You can limit the number of returned rows using the row range construct `.[x:y]`.
Note that the elements are [zero-indexed](https://en.wikipedia.org/wiki/Zero-based_numbering).

```shell
$ sq '.actor | .[3]'      # Return row index 3 (fourth row)
$ sq '.actor | .[0:3]'    # Return rows 0-3
$ sq '.actor | .[:3]'     # Same as above; return rows 0-3
$ sq '.actor | .[100:]'   # Return rows 100 onwards
```

At the backend, a row range becomes a `LIMIT x OFFSET y` clause:

```sql
SELECT * FROM "actor" LIMIT 3 OFFSET 2
```

## Column aliases

You can give an alias to a column expression using `.name:alias`.
For example:

```shell
$ sq '.actor | .first_name:given_name, .last_name:family_name'
given_name   family_name
PENELOPE     GUINESS
NICK         WAHLBERG
```

On the backend, `sq` uses the SQL `column AS alias` construct. The query
above would be rendered into SQL like this:

```sql
SELECT "first_name" AS "given_name", "last_name" AS "family_name" FROM "actor"
```

This works for any type of column expression, including functions.

```shell
$ sq '.actor | count(*):quantity'
quantity
200
```

It's common to alias [whitespace names](#whitespace-names):

```shell
$ sq '.actor | ."first name":first_name, ."last name":last_name'
given_name  family_name
PENELOPE    GUINESS
NICK        WAHLBERG
```

## Whitespace names

If a table or column name has whitespace, simply surround the name in quotes.

```shell
$ sq '.actor | ."first name", ."last name"'
$ sq '."film actor" | .actor_id'
```

## Joins

Use the `join` construct to join two tables. You can join tables in a single data source,
or across data sources. That is, you can join a Postgres table and a CSV file, or
an Excel worksheet and a JSON file, etc.

{{< alert icon="⚠️" >}}
`sq` only implements a limited subset of the SQL JOIN standard.

At this time,
you cannot join more than two tables. There's
an [open issue](https://github.com/neilotoole/sq/issues/12).

Also, the only JOIN variant available is the plain old JOIN. There's no
support for `RIGHT OUTER JOIN`, `CROSS JOIN`, etc. See the
[issue](https://github.com/neilotoole/sq/issues/157).
{{< /alert >}}

Take the `film` and `language` tables from the [Sakila](/docs/develop/sakila/) DB:

```text
TABLE     ROWS  COL NAMES
film      1000  film_id, title, description, release_year, language_id [...]
language  6     language_id, name, last_update
```

Note that both tables have a column `language_id`. This is the simplest join:

```shell
$ sq '.film, .language | join(.language_id)'
title             name      [...]
ACADEMY DINOSAUR  English
ACE GOLDFINGER    English
```

Behind the scenes, the executed SQL looks like:

```sql
SELECT * FROM "film"
    INNER JOIN "language" ON "film"."language_id" = "language"."language_id"
```

If the joined columns have different names, then you need to explicitly specify
those names. Generally it's safer to specify `.table.column`, instead of
just the column name. Let's pretend the `actor` table's primary key was named `id`
instead of `actor_id`. Then the query would be:

```shell
$ sq '.actor, .film_actor | join(.actor.id == .film_actor.actor_id)'
```

This would produce SQL like:

```sql
SELECT * FROM "actor"
    INNER JOIN "film_actor" ON "actor"."id" = "film_actor"."actor_id"
```

Thus, a join query has this structure:

| Handle (optional) | Table Selectors       | Join constraint                                 | Column expressions                       |
| ----------------- | --------------------- | ----------------------------------------------- | ---------------------------------------- |
| `@sakila_pg`      | `.actor, .film_actor` | `join(.actor.actor_id == .film_actor.actor_id)` | `.actor.first_name, .film_actor.film_id` |

### Cross-source joins

`sq` can join across data sources. Below, we join a CSV file with a Postgres table.

```shell
sq '@actor_csv.data, @sakila_pg12.film_actor | join (.data.id == .film_actor.actor_id) | .data.first:first_name, .film_actor.film_id'
first_name  film_id
PENELOPE    1
PENELOPE    23
```

This would turn into this SQL query:

```sql
SELECT "data"."first" AS "first_name", "film_actor"."film_id" FROM "data"
    INNER JOIN "film_actor" ON "data"."id" = "film_actor"."actor_id"
```

If there is no ambiguity in the column names, you can use the short-form selectors:

```shell
$ sq '@actor_csv.data, @sakila_pg12.film_actor | join (.id == .actor_id) | .first:first_name, .film_id'
```

This would translate to:

```sql
SELECT "first" AS "first_name", "film_id" FROM "data"
    INNER JOIN "film_actor" ON "id" = "actor_id"
```

{{< alert icon="👉" >}}
How do cross-source joins work?

The implementation is very basic (and could be dramatically enhanced).

1. `sq` copies the full contents of the left table to the [scratch DB](/docs/concepts/#scratch-db).
1. `sq` copies the full content of the right table to the scratch DB.
1. `sq` executes the query against the scratch DB.

Given that this naive implementation perform a full copy of both tables, cross-source joins
are only suitable for smaller datasets.
{{< /alert >}}

## Functions

### `count`

The no-arg `count` function returns the total number of rows.

```shell
$ sq '.actor | count'
count
200
```

That renders to SQL as:

```sql
SELECT count(*) AS "count" FROM "actor"
```

With an argument, `count(.x)` returns a count of the number of times
that `.x` is not null in a group.

```shell
# count of non-null values in col first_name
$ sq '.actor | count(.first_name)'
```

You can also supply an alias:

```shell
$ sq '.actor | count:quantity'
quantity
200
```

### `count_unique`

`count_unique` counts the unique non-null values of a column.

```shell
$ sq '.actor | count_unique(.first_name)'
count_unique(.first_name)
128
```

### `group_by`

Use `group_by` to [group](<https://en.wikipedia.org/wiki/Group_by_(SQL)>) results.

```shell
$ sq '.payment | .customer_id, sum(.amount) | group_by(.customer_id)'
```

This translates into:

```sql
SELECT "customer_id", sum("amount") FROM "payment" GROUP BY "customer_id"
```

You can use multiple terms in `group_by`:

```shell
$ sq '.payment | .customer_id, .staff_id, sum(.amount) | group_by(.customer_id, .staff_id)'
```

You can also use functions inside `group_by`. For example, to group the payment
amount by month:

```shell
$ sq '.payment | strftime("%Y/%m", .payment_date), sum(.amount) | group_by(strftime("%Y/%m", .payment_date))'
strftime('%Y/%m', "payment_date")  sum("amount")
2005/05                            4824.429999999861
2005/06                            9631.87999999961
```

That translates into:

```sql
SELECT strftime('%Y/%m', "payment_date"), sum("amount") FROM "payment"
GROUP BY strftime('%Y/%m', "payment_date")
```

In practice, you probably want to use [column aliases](#column-aliases):

```shell
$ sq '.payment | strftime("%Y/%m", .payment_date):month, sum(.amount):amount | group_by(.month)'
month    amount
2005/05  4824.429999999861
2005/06  9631.87999999961
```

{{< alert icon="👉" >}}
Note the `strftime` function in the example above. That function is specific
to [SQLite](https://www.sqlite.org/lang_datefunc.html): it won't work with Postgres,
MySQL etc. `sq` passes functions through
to the backend, and some of those functions won't be portable to other data sources.

This situation is contra to `sq`'s goal of being cross-source compatible. To that end,
it's possible that the syntax for invoking a DB-specific function may change to make
it clear that a non-portable function is being invoked.

TLDR: Use DB-specific functions with caution.
{{< /alert >}}

### `order_by`

Use `order_by()` to sort results.

```shell
$ sq '.actor | order_by(.first_name)'
actor_id  first_name  last_name  last_update
71        ADAM        GRANT      2006-02-15T04:34:33Z
132       ADAM        HOPPER     2006-02-15T04:34:33Z
```

This translates to:

```sql
SELECT * FROM "actor" ORDER BY "first_name"
```

Change the sort order by appending `+` (ascending) or `-` (descending)
to the column selector:

```shell
$ sq '.actor | order_by(.first_name+, .last_name-)'
actor_id  first_name  last_name  last_update
132       ADAM        HOPPER     2006-02-15T04:34:33Z
71        ADAM        GRANT      2006-02-15T04:34:33Z
```

That query becomes:

```sql
SELECT * FROM "actor" ORDER BY "first_name" ASC, "last_name" DESC
```

#### Synonyms

For interoperability with `jq`, you can use the
[`sort_by`](<https://stedolan.github.io/jq/manual/v1.6/#sort,sort_by(path_expression)>)
synonym:

```shell
$ sq '.actor | sort_by(.first_name)'
```

### `unique`

`unique` filters results, returning only unique values.

```shell
# Return only unique first names
$ sq '.actor | .first_name | unique'
```

The function maps to the SQL `DISTINCT` keyword:

```sql
SELECT DISTINCT "first_name" FROM "actor"
```
