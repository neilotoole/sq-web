---
title: "sq"
description: "Execute SLQ query against data source"
draft: false
images: []
menu:
  docs:
    parent: "cmd"
weight: 2010
toc: false
---
Use the root `sq` cmd to execute queries against data sources.

## Pipe Data

For file-based sources (such as CSV or XLSX), you can [`sq add`](/docs/cmd/add) the source file,
but you can also use the UNIX pipe mechanism:

```shell
$ cat ./example.xlsx | sq .Sheet1
```

Similarly, you can [`inspect`](/docs/cmd/inspect):

```shell
$ cat ./example.xlsx | sq inspect
```

## Predefined variables

The `--arg` flag passes a value to `sq` as a [predefined variable](/docs/query/#predefined-variables):

```shell
$ sq --arg first "TOM" '.actor | .first_name == $first'
actor_id  first_name  last_name  last_update
38        TOM         MCKELLEN   2020-06-11T02:50:54Z
42        TOM         MIRANDA    2020-06-11T02:50:54Z
```

## Output

`sq` can output results in many formats.

| Flag      | Shorthand | Format                                       |
|-----------|-----------|----------------------------------------------|
| `--table` | `-t`      | Text table                                   |
| `--json`  | `-j`      | JSON                                         |
| `--jsona` | `-A`      | LF-delimited JSON arrays                     |
| `--jsonl` | `-l`      | LF-delimited JSON objects                    |
| `--raw`   | `-r`      | Raw bytes, without any encoding or delimiter |
| `--xlsx`  | `-x`      | Excel XLSX                                   |
| `--csv`   | `-c`      | CSV                                          |
| `--tsv`   | `-T`      | TSV                                          |
| `--md`    |           | Markdown table                               |
| `--html`  |           | HTML table                                   |
| `--xml`   | `-X`      | XML                                          |

By default, `sq` outputs to `stdout`. You can use shell redirection to write
`sq` output to a file:

```shell
$ sq --csv .actor  > actor.csv
```

But you can also use `--output` (`-o`) to specify a file:

```shell
$ sq --csv .actor -o actor.csv
```

## Reference

{{< readfile file="sq.help.txt" code="true" lang="text" >}}
