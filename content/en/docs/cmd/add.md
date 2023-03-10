---
title: "sq add"
description: "Add data source"
draft: false
images: []
menu:
  docs:
    parent: "cmd"
weight: 3000
toc: false
---
Use `sq add` to add a data source. The source can be a SQL database, or a document
such as a CSV or Excel file. This action will add an entry to `sq`'s
[config file](/docs/overview/#config).

If you later want to change the source, generally the easiest solution is to
`sq rm @handle` and then `sq add` again. However, you can also directly edit
the config file (e.g. `vi ~/.config/sq/sq.yml`).

A data source has three main elements:

- `driver`: such as `postgres`, or `csv`. You may also see this referred to as the _source type_
  or simply _type_.
- `handle`: such as `@sakila_pg`. A handle always starts with `@`. The handle is used to refer
  to the data source.
- `location`: such as `postgres://user:p_ssW0rd@@localhost/sakila`. For
  a document source, _location_ may just be a file path, e.g. `/Users/neilotoole/sakila.csv`.

The format of the command is:

```shell
sq add [--handle HANDLE] [--driver DRIVER] [--opts OPTS] LOCATION
```

For example, to add a postgres data source:

```shell
$ sq add postgres://sakila:p_ssW0rd@localhost/sakila
@sakila_pg  postgres  sakila@localhost/sakila
```

Note that flags can generally be omitted. If `--handle` is omitted,
`sq` will generate a handle. In the example above, the generated handle
is `@sakila_pg`. Usually `--driver` can also be omitted, and `sq`
will determine the driver type.

To add a document source, you can generally just add the file path:

```shell
sq add ~/customers.csv
```

## Password visibility

In the Postgres example above, the _location_ string includes the database password. This is a
security hazard, as the password value is visible on the command line, and in
shell history etc. You can use the `--password` / `-p` flag to be prompted
for the password.

```shell
$ sq add 'postgres://user@localhost/sakila' -p
Password: ****
```

You can also read the password from a file or a shell variable. For example:

```shell
# Add a source, but read password from an environment variable
$ export PASSWORD='open:;"_Ses@me'
$ sq add 'postgres://user@localhost/sakila' -p <<< $PASSWORD

# Same as above, but instead read password from file
$ echo 'open:;"_Ses@me' > password.txt
$ sq add 'postgres://user@localhost/sakila' -p < password.txt
```

## Reference

{{< readfile file="add.help.txt" code="true" lang="text" >}}
