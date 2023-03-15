---
title: "XLSX (Excel)"
description: "XLSX (Excel)"
draft: false
images: []
weight: 4060
toc: true
---
The `sq` XLSX driver implements connectivity
for Microsoft [XLSX](https://www.microsoft.com/en-us/microsoft-365/excel)
files.

Note that XLSX sources are read-only. That is to say, while you can query the XLSX
source as if it were a SQL database, you cannot use `sq` to insert values into the XLSX file.

## Add source

When adding an XLSX source via [`sq add`](/docs/cmd/add), the location string is simply the filepath.
For example:

```shell
 $ sq add ./sakila.xlsx
@sakila_xlsx  xlsx  sakila.xlsx
```

You can also pass an absolute filepath (and, in fact, any relative path is expanded to
an absolute path when saved to `sq`'s config).

## Worksheets

When an XLSX source is added, `sq` treats each sheet as a separate database table.
Thus a sheet named `actor` can be queried as `@sakila_xlsx.actor`.

{{< alert icon="⚠️" >}}
At this time, only worksheets that are legal `sq` table names are accessible via `sq`.
For example, a worksheet with whitespace in the name is not accessible. So, `actor_names` is OK,
but `Actor Names` is not.

This limitation also applies to column names from the header row. Thus `first_name` is OK,
but `First Name` is not.

There is an open [issue](https://github.com/neilotoole/sq/issues/98) for this.
{{< /alert >}}

## Header row

By default, `sq` treats each sheet as raw data, without a header row. The fields (columns)
are then named `A`, `B`, `C`, etc.

```shell
$ sq @sakila_noheader_xlsx.actor
A    B            C             D
1    PENELOPE     GUINESS       2020-02-15T06:59:28Z
2    NICK         WAHLBERG      2020-02-15T06:59:28Z
```

But often an XLSX sheet will have a header row. In that case, use the `--header=true` option:

```shell
sq add sakila.xlsx --opts header=true
```

Then the sheet header row names will become the column names.

```shell
$ sq @sakila_xlsx.actor
actor_id  first_name   last_name     last_update
1         PENELOPE     GUINESS       2020-02-15T06:59:28Z
2         NICK         WAHLBERG      2020-02-15T06:59:28Z
```

{{< alert icon="👉" >}}
A known limitation is that the `header` option is set on a per-source basis, not per-sheet.
That is to say, each of the sheets in the XLSX source should have a header, or none of the
sheets should have a header.
{{< /alert >}}
