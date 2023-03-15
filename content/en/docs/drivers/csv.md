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

Note that the CSV driver is a read-only data source. That is to say, while you can query the CSV
source as if it were a SQL table, you cannot insert values into the CSV source.

## Add source

When adding a CSV source via [`sq add`](/docs/cmd/add), the location string is simply the filepath.
For example:

```shell
$ sq add ./person.csv
@person_csv  csv  person.csv
```

You can also pass an absolute filepath (and, in fact, any relative path is expanded to
an absolute path when saved to `sq`'s config).

Usually you can omit the `--driver=csv` flag, because `sq` will inspect the file contents
and figure out that it's a CSV file. However, it's safer to explicitly specify the flag.

```shell
sq add --driver=csv ./person.csv
```

The same is true for TSV files. You can specify the driver explicitly:

```shell
$ sq add ./person.tsv
@person_tsv  tsv  person.tsv
```

But, if you omit the driver, `sq` can generally figure out that it's a TSV file.

```shell
sq add ./person.tsv
```

## Monotable

`sq` considers CSV to be a _monotable_ data source (unlike, say, a Postgres data source, which
obviously can have many tables). Like all other `sq` monotable sources,
the source's data is accessed via the synthetic `.data` table. For example:

```shell
$ sq @person_csv.data
uid  username    email                  address_id
1    neilotoole  neilotoole@apache.org  1
2    ksoze       kaiser@soze.org        2
```

## Delimiters

It's common to encounter delimiters other than comma. TSV (tab) is the most common, but other
variants exist, e.g. pipe (`a|b|c`). Use the `--opts delim=DELIM` flag to specify
the delimiter. Because the delimiter is often a shell token (e.g. `|`), the `delim` option
requires text aliases. For example:

```shell
sq add ./person.csv --opts delim=pipe
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
  $ sq add --driver=tsv ./person.tsv
  $ sq add --driver=csv --opts delim=tab ./person.tsv
  $ sq add ./person.tsv
  ```

## Header row

By default, `sq` treats CSV files as raw data files, without a header row. The fields (columns)
are then named `A`, `B`, `C`, etc.

```shell
$ sq @person_noheader_csv.data
A  B           C                      D
1  neilotoole  neilotoole@apache.org  1
2  ksoze       kaiser@soze.org        2
```

But often a CSV file will have a header row. For example:

```text
uid,username,email,address_id
1,neilotoole,neilotoole@apache.org,1
2,ksoze,kaiser@soze.org,2
```

In this case, use the `--header=true` option:

```shell
$ sq add --opts header=true ./person.csv
@person_csv  csv  person.csv
```

Then the CSV header field names will become the column names.

```shell
sq @person_csv.data
uid  username    email                  address_id
1    neilotoole  neilotoole@apache.org  1
2    ksoze       kaiser@soze.org        2
```

