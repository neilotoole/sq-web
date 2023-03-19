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

## Output

`sq` can output results in many formats.


## Reference

{{< readfile file="sq.help.txt" code="true" lang="text" >}}
