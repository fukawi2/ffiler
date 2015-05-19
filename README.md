# ffiler
File Filer; sorts files into various filing patterns such as by date, file hash, file prefix etc

# Usage

## By Modified Timestamp
This will sort files into a tree structure based on the modified timestamp of
the file.

### Example
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

### Syntax
* Sort to 1-level (YYYY/): `ffiler -y tosort/*`
* Sort to 2-levels (YYYY/Month/): `ffiler -m tosort/*`
* Sort to 3-levels (YYYY/Month/Day/): `ffiler -d tosort/*`

## By MD5 Hashes
Hash either the file *name* or the file *content* (slower), then place the file
into a tree based on the number of characters at the start of the hash.

### Example
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

### Syntax
* Sort using the MD5 hash of the file *name*: `ffiler -s3 tosort/*`
* Sort using the MD5 hash of the file *content*: `ffiler -S3 tosort/*`

## By Filename
Similar to filing by hash, but don't bother to hash anything first (just take
the first X characters of the filename).

### Example
An example tree (directories only) filing to a depth of 2 characters:

```
├── e
│   ├── x
│   └── l
├── f
│   ├── f
│   └── i
└── t
    └── e
```

### Syntax
* Sort to 1-level: `ffiler -f1 tosort/*`
* Sort to 2-levels: `ffiler -f2 tosort/*`
* Sort to 8-levels: `ffiler -f8 tosort/*`
