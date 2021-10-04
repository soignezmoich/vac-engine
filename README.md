# VacEngine

## Development quick start

1) Set environment variables ([direnv](https://direnv.net/) is good)

    DATABASE_URL=postgres://user@host/db

2) Create database. This WILL DROP IT and recreate it.

    make db

3) Start server

    make server

4) Connect to localhost on port 4000

<https://localhost:4000>

Log in with:

Email: **admin@admin.com**

Password: **12341234**


## Compiling a release

NOTE: If you build in your development machine, be sure to stop `make server`
prior to build.

Compile time env var must be set prior to build.

The application is the compiled with:

`make clean`
`make release`

This will generate the application in:

`_build/prod/rel/vac_engine`

This whole folder must be then deployed.

The binary to control the app is:

`_build/prod/rel/vac_engine/bin/vac_engine`

## Environment variables

The application is configured throught environment variables.

There is two types of environment variables.

Compile time env var:

- `SESSION_SIGNING_SALT`
- `SESSION_ENCRYPTION_SALT`
- `SESSION_KEY`
- `LIVE_VIEW_SALT`

Run time env var:

- `DATABASE_URL`
- `HOST`
- `PORT`
- `SECRET_KEY_BASE`
- `POOL_SIZE`

### `SESSION_SIGNING_SALT`

This is the session signing salt. This is a salt and not a secret.

Must be a random string between 8 and 32 characters long.

This is a compile time variable.

### `SESSION_ENCRYPTION_SALT`

This is the session encryption salt. This is a salt and not a secret.

Must be a random string between 8 and 32 characters long.

This is a compile time variable.

### `SESSION_KEY`

This is the name of the cookie used to store the session.

Must be a string between 4 and 16 characters long.

This is a compile time variable.

### `LIVE_VIEW_SALT`

This is the live view salt signing salt. This is a salt and not a secret.

Must be a random string between 8 and 32 characters long.

This is a compile time variable.

### `DATABASE_URL`

The database URL to use.

[Format](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING)

When using make to run test, the Makefile will override `DATABASE_URL` with
`DATABASE_TEST_URL`.

### `HOST`

The public host of the server.

This is used to generate redirect URLs.

For example, if set to `myapp.example.com` then all full URLs would be
`https://myapp.example.com/path`.

This is only a hostname, protocol will be forced to `https` and no path can be
added.

### `PORT`

The HTTP port to listen on.

### `ADDRESS`

The IP address to bind the HTTP listener to. By default it will use `::0` which
will bind to all ipv6 and ipv4 addresses. You can set it to either an ipv6 or
ipv4 address. Set it to `127.0.0.1` for ipv4 only localhost listening.

### `SECRET_KEY_BASE`

This is the secret used to derive all the keys used in the application.

Must be a random string between 64 and 120 characters long.

This is a secret and must be protected.

### `POOL_SIZE`

The postgresql pool size. This is the number of database connection to open.

Default to 10.

## Processor expressions

### Types

- `boolean` - `true` or `false` (`0` and `nil` are not `false` and truthy values
  are not `true`)
- `integer` - an integer
- `number` - any number, integer or decimal (this type must NOT be used for
  equality)
- `string` - a string, length limited to 100 characters
- `enum` - a string with a specific set of pre-defined values
- `date` - a date with a precision of one day
- `datetime` - a date with time, time has a 1 second precision

### Functions

- `is_true(a)` - a is true
- `is_false(a)` - a is false
- `not(a)` - invert a
- `eq(a, b)` - a is equal to b. Not to be used for non integer numbers.
- `neq(a, b)` - a is not equal to b
- `gt(a, b)` - a is greater than b
- `gte(a, b)` - a is greater than or equal to b
- `lt(a, b)` - a is less than b
- `lte(a, b)` - a is less than or equal to b
- `add(a, b)` - add a and b
- `sub(a, b)` - subtract b from a
- `mult(a, b)` - multiply a with b
- `div(a, b)` - divide a with b
- `contains(a, b)` - check if a contains b



### date

Predicate operators:

| name | arguments |
|------|-----------|
| =    |a:date|
| !=   |a:date|
| olderThanDays | a:number |
| olderThanMonths |a:number |
| olderThanYears |a:number |
| older=ThanDays | a:number |
| older=ThanMonths |a:number |
| older=ThanYears |a:number |
| youngerThanDays | a:number |
| youngerThanMonths | a:number |
| youngerThanYears | a:number |
| younger=ThanDays | a:number |
| younger=ThanMonths | a:number |
| younger=ThanYears | a:number |

> note 2: if you need to define a "between a and b", use two predicates

Assignation operators:

| name | arguments |
|------|-----------|
|addDays|a:number|
|addMonths|a:number|
|addYears|a:number|

> note: a can be a variable or a constant



