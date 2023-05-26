---
title: "CSV & friends"
description: "CSV & friends"
draft: false
images: []
weight: 4050
toc: true
---
The `sq` CSV driver implements connectivity for [CSV](https://en.wikipedia.org/wiki/Comma-separated_values)
and variants, such as [TSV](https://en.wikipedia.org/wiki/Tab-separated_values), pipe-delimited, etc..

Note that the CSV data sources are read-only. That is to say, while you can query the CSV
source as if it were a SQL table, you cannot insert values into the CSV source.

## Add source

When adding a CSV source via [`sq add`](/docs/cmd/add), the location string is simply the filepath.
For example:

```shell
$ sq add ./actor.csv
@actor_csv  csv  actor.csv
```

You can also pass an absolute filepath (and, in fact, any relative path is expanded to
an absolute path when saved to `sq`'s config).

Usually you can omit the `--driver=csv` flag, because `sq` will inspect the file contents
and figure out that it's a CSV file. However, it's safer to explicitly specify the flag.

```shell
sq add --driver=csv ./actor.csv
```

The same is true for TSV files. You can specify the driver explicitly:

```shell
$ sq add ./actor.tsv
@actor_tsv  tsv  actor.tsv
```

But, if you omit the driver, `sq` can generally figure out that it's a TSV file.

```shell
sq add ./actor.tsv
```

## Monotable

`sq` considers CSV to be a _monotable_ data source (unlike, say, a Postgres data source, which
obviously can have many tables). Like all other `sq` monotable sources,
the source's data is accessed via the synthetic `.data` table. For example:

```shell
$ sq @actor_csv.data
actor_id  first_name   last_name     last_update
1         PENELOPE     GUINESS       2020-02-15T06:59:28Z
2         NICK         WAHLBERG      2020-02-15T06:59:28Z
```

## Delimiters

It's common to encounter delimiters other than comma. TSV (tab) is the most common, but other
variants exist, e.g. pipe (`a|b|c`). Use the `--driver.csv.delim` flag to specify
the delimiter. Because the delimiter is often a shell token (e.g. `|`), the `delim` option
requires text aliases. For example:

```shell
sq add ./actor.csv --driver.csv.delim=pipe
```

The accepted values are:

| Delim    | Value                     |
|----------|---------------------------|
| `comma`  | `,`                       |
| `space`  | <code>&nbsp;</code>       |
| `pipe`   | <code>&vert;</code>       |
| `tab`    | <code>&nbsp;&nbsp;</code> |
| `colon`  | `:`                       |
| `semi`   | `;`                       |
| `period` | `.`                       |

Note:

- `comma` is the default. You generally never need to specify this.
- `tab` is the delimiter for TSV files. Because this is such a common variant, `sq` allows
  you to specify `--driver=tsv` instead. But usually `sq` will figure out that it's a TSV file.
  The following are equivalent:

  ```shell
  $ sq add --driver=tsv ./actor.tsv
  $ sq add --driver=csv --driver.csv.delim=tab ./actor.tsv
  $ sq add ./actor.tsv
  ```

## Header row

By default, `sq` treats CSV files as raw data files, without a header row. The fields (columns)
are then named `A`, `B`, `C`, etc.

```shell
$ sq @actor_noheader_csv.data
A    B            C             D
1    PENELOPE     GUINESS       2020-02-15T06:59:28Z
2    NICK         WAHLBERG      2020-02-15T06:59:28Z
```

But often a CSV file will have a header row. For example:

```text
actor_id,first_name,last_name,last_update
1,PENELOPE,GUINESS,2020-02-15T06:59:28Z
2,NICK,WAHLBERG,2020-02-15T06:59:28Z
```

In that case, use the `--ingest.header` flag:

```shell
sq add --ingest.header ./actor.csv
```

Then the CSV header field names will become the column names.

```shell
$ sq @actor_csv.data
actor_id  first_name   last_name     last_update
1         PENELOPE     GUINESS       2020-02-15T06:59:28Z
2         NICK         WAHLBERG      2020-02-15T06:59:28Z
```

