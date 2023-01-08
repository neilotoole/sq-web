---
title : "sq"
description: "sq is for wrangling data"
lead: "wrangle data"
draft: false
images: []
---
`sq` is a free/libre [open-source](https://github.com/neilotoole/sq) data wrangling swiss-army knife
to inspect, query, join, import, and export data. You could think of `sq`
as [jq](https://stedolan.github.io/jq/) for databases and documents, facilitating one-liners
like:

```shell
sq '@postgres_db | .actor | .first_name, .last_name | .[0:5]'
```

## Installation

{{< tabs name="sq-install" >}}
{{{< tab name="mac" codelang="shell" >}}brew install neilotoole/sq/sq{{< /tab >}}
{{< tab name="linux" codelang="shell" >}}/bin/sh -c "$(curl -fsSL https://sq.io/install.sh)"{{< /tab >}}}
{{< tab name="win" codelang="shell">}}scoop bucket add sq https://github.com/neilotoole/sq
scoop install sq{{< /tab >}}}
{{% tab name="more" %}}
Install options for `apt`, `yum`, `apk`, `pacman`, `yay` over [here](/docs/install).
{{% /tab %}}}
{{< /tabs >}}
