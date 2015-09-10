# ffiler
File Filer; sorts files into structured directory tree. Tree can be structured
based on various designs such as date (_file modification time_), file hash,
file prefix etc

# Usage

## Filing Method
There are various filing tree structures available:

- Modified Timestamp
- MD5 hash of file name
- MD5 hash of file contents (slower)
- Leading characters of file name
- MIME type of file

### Modified Timestamp
An example tree (directories only) filing to a depth of 2 (YYYY/Month/):

```
├── 2014
│   ├── 01-Jan
│   ├── 02-Feb
│   ├── ...
│   ├── 11-Nov
│   └── 12-Dec
└── 2015
    ├── 01-Jan
    ├── 02-Feb
    ├── 03-Mar
    ├── 04-Apr
    └── 05-May
 ```

### By MD5 Hash
An example tree (directories only) filing to a depth of 2 characters:

```
├── 2
│   ├── 2
│   └── b
├── a
│   ├── 1
│   └── e
└── e
    ├── 1
    └── 7
```

### By Filename
Similar to filing by hash, but don't bother to hash anything first (just take
the first X characters of the filename).

An example tree (including files) filing to a depth of 2 characters:

```
├── e
│   ├── l
│   │   └── elephant
│   └── x
│       └── example
├── f
│   ├── f
│   │   └── ffiler
│   └── i
│       └── file
└── t
    └── e
            └── test
```

### Mime type

An example tree (including files):

```
├── application
│   └── postscript
│       └── mylogo.eps
└── image
    ├── jpeg
    │   ├── mylogo.jpg
    │   ├── yourlogo.jpg
    │   └── herlogo.jpeg
    └── png
        └── hislogo.png
```

## Filing Depth
Most of the filing methods require a depth for the resulting tree structure.
Valid depths depend on the filing method.

For string-based methods (MD5 hashes or filenames) the depth is the number of
characters (positive integer) to build the tree with.

*Example:* `ffiler -ss -d2` _(Sort to the second character as above)_

For timestamp-based methods (modified time) the depth is the timestamp
granularity:

- `y` = Year   (eg `2010/`)
- `m` = Month  (eg `2010/01-Jan/`)
- `d` = Day    (eg `2010/01-Jan/15/`)
- `H` = Hour   (eg `2010/01-Jan/15/18/`)
- `M` = Minute (eg `2010/01-Jan/15/18/20/`)
- `S` = Second (eg `2010/01-Jan/15/18/20/34/`)

*Example:* `ffiler -sm -dm` _(Sort to the "month" level)_

## Action

ffiler can move (default), copy, symlink or hardlink files into the destination
tree. The flags for these are:

```
-M  Move
-C  Copy
-L  Symbolic Link
-H  Hard Link
```

# Installation

## Arch Linux

PKGBUILD is in the AUR: https://aur.archlinux.org/packages/ffiler-git/
