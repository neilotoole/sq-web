---
title : "sq"
description: "sq is for wrangling data"
lead: "wrangle data"
draft: false
images: []
---

`sq` is a free/libre [open source](https://github.com/neilotoole/sq) <a href="">open-source</a> swiss-army knife
to inspect, query, join, import, and export data. You can think of it as [jq](https://stedolan.github.io/jq/) for
relational data, whether that data is in a document or database.

`sq` has a `jq`-style query language that looks like this: `sq '.actor | .first_name, .last_name | .[0:5]'`.
The query language is limited in scope, but for complex queries, you can fall back to database-native
SQL queries.



### Install

{{< tabs name="sq-install" >}}
{{{< tab name="mac" codelang="shell" >}}brew install neilotoole/sq/sq{{< /tab >}}
{{< tab name="linux" codelang="shell" >}}/bin/sh -c "$(curl -fsSL https://sq.io/install.sh)"{{< /tab >}}}
{{< tab name="win"  codelang="shell" >}}scoop bucket add sq https://github.com/neilotoole/sq
scoop install sq{{< /tab >}}}
{{< /tabs >}}
