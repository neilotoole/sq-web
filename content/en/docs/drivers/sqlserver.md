---
title: "SQL Server"
description: "SQL Server"
draft: false
images: []
weight: 4030
toc: false
aliases:
- /docs/driver/sql-server
---
The `sq` SQL Server driver implements connectivity for
the Microsoft [SQL Server](https://www.microsoft.com/en-us/sql-server) and
[Azure SQL Edge](https://azure.microsoft.com/en-us/products/azure-sql/edge/) databases.
The driver implements all optional driver features.

## Add source

Use [`sq add`](/docs/cmd/add) to add a source.  The location argument should
start with `sqlserver://`. For example:

```shell
sq add 'sqlserver://sakila:p_ssW0rd@localhost?database=sakila'
```
