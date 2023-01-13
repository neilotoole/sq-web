---
title: "Install"
description: "Install sq on macOS, Windows, Linux"
lead: ""
draft: false
images: []
weight: 99
toc: true
---

`sq` can be installed from source, via an install script, or via package managers for various platforms.

## Quick install

Use `install.sh` in most cases other than [Windows](#windows).

```shell
/bin/sh -c "$(curl -fsSL https://sq.io/install.sh)"
```

`install.sh` determines what OS is in use, and attempts to use an appropriate package manager.
The following have been tested:

| Package Manager | OS / Distribution                    | Architecture    |
|-----------------|--------------------------------------|-----------------|
| `apt`           | Debian-based (Ubuntu etc.)           | `arm64` `amd64` |
| `yum`           | RPM-based (Rocky Linux, Fedora etc.) | `arm64` `amd64` |
| `apk`           | Alpine Linux                         | `arm64` `amd64` |
| `pacman`        | Arch Linux                           | `amd64`         |
| `yay`           | Arch Linux                           | `amd64`         |
| `brew`          | macOS                                | `arm64` `amd64` |
| `brew`          | Linux                                | `arm64`         |

You can view the source for `install.sh` on [GitHub](https://raw.githubusercontent.com/neilotoole/sq/master/install.sh).

## Shell completion

The install packages will generally install shell completion. Note that `sq` provides
extensive completion functionality. If installing from
source, it is highly recommended to manually install shell completion. For instructions:

```shell
sq completion --help
```

## Source

Requires [Go](https://go.dev/dl/).

```shell
git clone https://github.com/neilotoole/sq.git && cd sq && go install
```

## Binaries

Pre-built binaries are available from [GitHub releases](https://github.com/neilotoole/sq/releases).

## macOS

```shell
brew install neilotoole/sq/sq
```

## Windows

Requires [scoop](http://scoop.sh).

```shell
scoop bucket add sq https://github.com/neilotoole/sq
scoop install sq
```

## Linux

Generally you can use `install.sh`.

```shell
/bin/sh -c "$(curl -fsSL https://sq.io/install.sh)"
```

If you need more control over the install,
consult [install.sh source](https://raw.githubusercontent.com/neilotoole/sq/master/install.sh).
